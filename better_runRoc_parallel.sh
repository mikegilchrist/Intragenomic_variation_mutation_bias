#!/bin/bash
#
# Purpose: Fit ROC model
# Template from: https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") -i <input.file> -o <output.dir>

Script for running ROC analysis using a DNA FASTA file with the CDS of a genome <input>
stores output in <output.dir>

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-i  --input     Input FASTA file
-o  --output    Output directory
EOF
  exit
} 

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}


setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -i | --input) 
      input="${2-}
      shift
      ;; 
    -o | --output) # example named parameter
      output="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${input-}" ]] && die "Missing required parameter: input"
  [[ -z "${output-}" ]] && die "Missing required parameter: output"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# script logic here
nohup Rscript --vanilla Scripts/rocAnalysis.R -i "$input" -o "$output" -d 0 -s 20000 -a 20 -t 10 \
         -n 8 --est_csp --est_phi --est_hyp --max_num_runs 2 \
         --codon_table 1 &> "$output/$input.Rout" &
wait


msg "${RED}Read parameters:${NOFORMAT}"
msg "- input: ${input}"
msg "- output: ${output}"
msg "- arguments: ${args[*]-}"
