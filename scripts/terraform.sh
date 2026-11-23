#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS_DIR="$SCRIPT_DIR/../iac/terraform/stacks"

UP_ORDER=(network application database storage)
DOWN_ORDER=(storage database application network)

declare -A SELECTED=()
declare -A EXPLICIT=()

usage() {
  echo "Uso: $0 {up|down}"
  echo "     $0        seleciona interativamente quais stacks subir"
  exit 1
}

run_stack() {
  local action="$1"
  local stack="$2"
  local dir="$STACKS_DIR/$stack"

  echo "==> $stack: $action"
  terraform -chdir="$dir" init -input=false
  if [[ "$action" == "up" ]]; then
    terraform -chdir="$dir" apply -auto-approve -input=false
  else
    terraform -chdir="$dir" destroy -auto-approve -input=false -refresh=false
  fi
}

has_dependent_stack() {
  [[ -n "${SELECTED[application]:-}" || -n "${SELECTED[database]:-}" ]]
}

render_selection() {
  local index=1 stack marker origin

  echo "Selecione as stacks para subir:"
  for stack in "${UP_ORDER[@]}"; do
    if [[ -n "${SELECTED[$stack]:-}" ]]; then
      marker="[x]"
    else
      marker="[ ]"
    fi
    origin=""
    if [[ "$stack" == "network" && -n "${SELECTED[network]:-}" && -z "${EXPLICIT[network]:-}" ]]; then
      origin=" (auto)"
    fi
    echo "  $index) $marker $stack$origin"
    ((index++))
  done
  echo "Digite os números separados por espaço, um por vez, 'f' para finalizar ou 'q' para cancelar."
}

toggle_stack() {
  local stack="$1"

  if [[ -z "${SELECTED[$stack]:-}" ]]; then
    SELECTED[$stack]=1
    EXPLICIT[$stack]=1
    echo "==> $stack adicionada"
    if [[ "$stack" == "application" || "$stack" == "database" ]] && [[ -z "${SELECTED[network]:-}" ]]; then
      SELECTED[network]=1
      echo "==> network adicionada automaticamente"
    fi
    return
  fi

  if [[ "$stack" == "network" && -z "${EXPLICIT[network]:-}" ]]; then
    EXPLICIT[network]=1
    echo "==> network agora é seleção explícita"
    return
  fi

  if [[ "$stack" == "network" ]] && has_dependent_stack; then
    echo "==> network não pode ser removida enquanto application/database estiverem selecionadas"
    return
  fi

  unset "SELECTED[$stack]" "EXPLICIT[$stack]"
  echo "==> $stack removida"

  if [[ "$stack" == "application" || "$stack" == "database" ]] && ! has_dependent_stack && [[ -z "${EXPLICIT[network]:-}" ]]; then
    unset "SELECTED[network]" "EXPLICIT[network]"
    echo "==> network removida automaticamente"
  fi
}

select_stacks() {
  local input token
  local -a tokens=()

  render_selection
  while true; do
    if ! read -r -p "> " input; then
      echo
      break
    fi

    tokens=()
    read -r -a tokens <<< "$input"

    if (( ${#tokens[@]} == 0 )); then
      break
    fi

    if [[ "${tokens[0]}" == "q" || "${tokens[0]}" == "Q" ]]; then
      echo "Seleção cancelada."
      return 1
    fi

    if [[ "${tokens[0]}" == "f" || "${tokens[0]}" == "F" ]]; then
      break
    fi

    for token in "${tokens[@]}"; do
      if [[ ! "$token" =~ ^[1-4]$ ]]; then
        echo "Entrada inválida: $token (use 1 a 4, 'f' ou 'q')"
        continue
      fi
      toggle_stack "${UP_ORDER[$((token - 1))]}"
    done

    render_selection
  done
}

confirm_run() {
  local stack found=0 answer

  echo "Stacks que serão executadas (nesta ordem):"
  for stack in "${UP_ORDER[@]}"; do
    if [[ -n "${SELECTED[$stack]:-}" ]]; then
      echo "  - $stack"
      found=1
    fi
  done

  if (( found == 0 )); then
    echo "Nenhuma stack selecionada. Nada será executado."
    return 1
  fi

  if ! read -r -p "Confirmar execução? [s/N] " answer; then
    echo
    return 1
  fi

  if [[ ! "$answer" =~ ^[sS]$|^[sS][iI][mM]$ ]]; then
    echo "Execução cancelada."
    return 1
  fi
}

run_selected_up() {
  local stack

  for stack in "${UP_ORDER[@]}"; do
    if [[ -n "${SELECTED[$stack]:-}" ]]; then
      run_stack up "$stack"
    fi
  done
}

if [[ $# -eq 0 ]]; then
  if ! select_stacks; then
    exit 0
  fi
  confirm_run || exit 0
  run_selected_up
  exit 0
fi

[[ $# -eq 1 ]] || usage

case "$1" in
  up)
    for stack in "${UP_ORDER[@]}"; do
      run_stack up "$stack"
    done
    ;;
  down)
    for stack in "${DOWN_ORDER[@]}"; do
      run_stack down "$stack"
    done
    ;;
  *)
    usage
    ;;
esac
