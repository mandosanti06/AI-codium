#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

{ set +x; } 2>/dev/null

# {{{ product.json
cp product.json{,.bak}

setpath() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath_json() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --argjson 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://go.microsoft.com/fwlink/?LinkID=533484#vscode"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item", "latestUrlTemplate": "https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest", "controlUrl": "https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json"}'

setpath "product" "introductoryVideosUrl" "https://go.microsoft.com/fwlink/?linkid=832146"
setpath "product" "keyboardShortcutsUrlLinux" "https://go.microsoft.com/fwlink/?linkid=832144"
setpath "product" "keyboardShortcutsUrlMac" "https://go.microsoft.com/fwlink/?linkid=832143"
setpath "product" "keyboardShortcutsUrlWin" "https://go.microsoft.com/fwlink/?linkid=832145"
setpath "product" "licenseUrl" "https://github.com/VSCodium/vscodium/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/VSCodium/vscodium/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"

if [[ "${DISABLE_UPDATE}" != "yes" ]]; then
  setpath "product" "updateUrl" "https://raw.githubusercontent.com/VSCodium/versions/refs/heads/master"

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    setpath "product" "downloadUrl" "https://github.com/VSCodium/vscodium-insiders/releases"
  else
    setpath "product" "downloadUrl" "https://github.com/VSCodium/vscodium/releases"
  fi

  # if [[ "${OS_NAME}" == "windows" ]]; then
  #   setpath_json "product" "win32VersionedUpdate" "true"
  # fi
fi

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "product" "nameShort" "VSCodium - Insiders"
  setpath "product" "nameLong" "VSCodium - Insiders"
  setpath "product" "applicationName" "codium-insiders"
  setpath "product" "dataFolderName" ".vscodium-insiders"
  setpath "product" "linuxIconName" "vscodium-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "vscodium-insiders"
  setpath "product" "serverApplicationName" "codium-server-insiders"
  setpath "product" "serverDataFolderName" ".vscodium-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.vscodium.VSCodiumInsiders"
  setpath "product" "win32AppUserModelId" "VSCodium.VSCodiumInsiders"
  setpath "product" "win32DirName" "VSCodium Insiders"
  setpath "product" "win32MutexName" "vscodiuminsiders"
  setpath "product" "win32NameVersion" "VSCodium Insiders"
  setpath "product" "win32RegValueName" "VSCodiumInsiders"
  setpath "product" "win32ShellNameShort" "VSCodium Insiders"
  setpath "product" "win32AppId" "{{EF35BB36-FA7E-4BB9-B7DA-D1E09F2DA9C9}"
  setpath "product" "win32x64AppId" "{{B2E0DDB2-120E-4D34-9F7E-8C688FF839A2}"
  setpath "product" "win32arm64AppId" "{{44721278-64C6-4513-BC45-D48E07830599}"
  setpath "product" "win32UserAppId" "{{ED2E5618-3E7E-4888-BF3C-A6CCC84F586F}"
  setpath "product" "win32x64UserAppId" "{{20F79D0D-A9AC-4220-9A81-CE675FFB6B41}"
  setpath "product" "win32arm64UserAppId" "{{2E362F92-14EA-455A-9ABD-3E656BBBFE71}"
  setpath "product" "tunnelApplicationName" "codium-insiders-tunnel"
  setpath "product" "win32TunnelServiceMutex" "vscodiuminsiders-tunnelservice"
  setpath "product" "win32TunnelMutex" "vscodiuminsiders-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "90AAD229-85FD-43A3-B82D-8598A88829CF"
  setpath "product" "win32ContextMenu.arm64.clsid" "7544C31C-BDBF-4DDF-B15E-F73A46D6723D"
else
  if [[ "${OS_NAME}" == "osx" ]]; then # AI-Codium stable macOS identity
    setpath "product" "nameShort" "AI-Codium"
    setpath "product" "nameLong" "AI-Codium"
    setpath "product" "applicationName" "ai-codium"
    setpath "product" "dataFolderName" ".ai-codium"
    setpath "product" "urlProtocol" "ai-codium"
    setpath "product" "serverApplicationName" "ai-codium-server"
    setpath "product" "serverDataFolderName" ".ai-codium-server"
    setpath "product" "darwinBundleIdentifier" "io.github.mandosanti06.aicodium"
    setpath "product" "reportIssueUrl" "https://github.com/mandosanti06/AI-codium/issues/new/choose"
    setpath "product" "licenseUrl" "https://github.com/mandosanti06/AI-codium/blob/master/LICENSE"
  else
    setpath "product" "nameShort" "VSCodium"
    setpath "product" "nameLong" "VSCodium"
    setpath "product" "applicationName" "codium"
    setpath "product" "urlProtocol" "vscodium"
    setpath "product" "serverApplicationName" "codium-server"
    setpath "product" "serverDataFolderName" ".vscodium-server"
    setpath "product" "darwinBundleIdentifier" "com.vscodium"
  fi
  setpath "product" "linuxIconName" "vscodium"
  setpath "product" "quality" "stable"
  setpath "product" "win32AppUserModelId" "VSCodium.VSCodium"
  setpath "product" "win32DirName" "VSCodium"
  setpath "product" "win32MutexName" "vscodium"
  setpath "product" "win32NameVersion" "VSCodium"
  setpath "product" "win32RegValueName" "VSCodium"
  setpath "product" "win32ShellNameShort" "VSCodium"
  setpath "product" "win32AppId" "{{763CBF88-25C6-4B10-952F-326AE657F16B}"
  setpath "product" "win32x64AppId" "{{88DA3577-054F-4CA1-8122-7D820494CFFB}"
  setpath "product" "win32arm64AppId" "{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}"
  setpath "product" "win32UserAppId" "{{0FD05EB4-651E-4E78-A062-515204B47A3A}"
  setpath "product" "win32x64UserAppId" "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}"
  setpath "product" "win32arm64UserAppId" "{{57FD70A5-1B8D-4875-9F40-C5553F094828}"
  setpath "product" "tunnelApplicationName" "codium-tunnel"
  setpath "product" "win32TunnelServiceMutex" "vscodium-tunnelservice"
  setpath "product" "win32TunnelMutex" "vscodium-tunnel"
  setpath "product" "win32ContextMenu.x64.clsid" "D910D5E6-B277-4F4A-BDC5-759A34EEE25D"
  setpath "product" "win32ContextMenu.arm64.clsid" "4852FC55-4A84-4EA1-9C86-D53BE3DF83C0"
fi

setpath_json "product" "tunnelApplicationConfig" '{}'

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cat product.json
# }}}

# include common functions
. ../utils.sh

# AICODIUM_PIPELINE_FUNCTIONS_BEGIN
apply_aicodium_patches() {
  local category file
  local LC_ALL=C
  local -a categories=(product platform workbench)

  for category in "${categories[@]}"; do
    for file in "../patches/aicodium/${category}/"*.json; do
      if [[ -f "${file}" ]]; then
        apply_aicodium_actions "${file}" || return 1
      fi
    done

    for file in "../patches/aicodium/${category}/"*.patch; do
      if [[ -f "${file}" ]]; then
        apply_patch "${file}" || return 1
      fi
    done
  done
}

validate_aicodium_actions() {
  local file=$1

  if ! jq -e '
    type == "array" and
    all(.[];
      type == "object" and
      .action == "remove" and
      (.paths | type == "array" and all(.[]; type == "string"))
    )
  ' "${file}" >/dev/null; then
    echo "Invalid AI-Codium action file: ${file}" >&2
    return 1
  fi
}

resolve_aicodium_path() {
  local entry_path=$1
  local entry_parent entry_name

  if [[ -d "${entry_path}" ]]; then
    cd -- "${entry_path}" && pwd -P
    return
  fi

  entry_parent=$(dirname -- "${entry_path}")
  entry_name=$(basename -- "${entry_path}")
  entry_parent=$(cd -- "${entry_parent}" && pwd -P) || return 1

  case "${entry_name}" in
    .)
      printf '%s\n' "${entry_parent}"
      ;;
    ..)
      cd -- "${entry_parent}/.." && pwd -P
      ;;
    *)
      printf '%s/%s\n' "${entry_parent}" "${entry_name}"
      ;;
  esac
}

apply_aicodium_actions() {
  local file=$1
  local entry_path raw_paths prepared_root resolved_entry_path
  local -a action_paths=()

  validate_aicodium_actions "${file}" || return 1
  prepared_root=$(pwd -P)

  if ! raw_paths=$(jq -r '.[] | .paths[]' "${file}"); then
    echo "Invalid AI-Codium action file: ${file}" >&2
    return 1
  fi

  if [[ -z "${raw_paths}" ]]; then
    return 0
  fi

  # Resolve and validate every target before changing any path. This keeps a
  # later invalid or escaping target from leaving an earlier target removed.
  while IFS= read -r entry_path; do
    entry_path="${entry_path%$'\r'}"
    action_paths+=("${entry_path}")

    resolved_entry_path=$(resolve_aicodium_path "${entry_path}") || {
      echo "Unable to resolve AI-Codium action path: ${entry_path}" >&2
      return 1
    }
    case "${resolved_entry_path}/" in
      "${prepared_root}/"*)
        if [[ "${resolved_entry_path}" == "${prepared_root}" ]]; then
          echo "AI-Codium action path resolves to prepared vscode root: ${entry_path}" >&2
          return 1
        fi
        ;;
      *)
        echo "AI-Codium action path escapes prepared vscode: ${entry_path}" >&2
        return 1
        ;;
    esac

    if [[ ! -e "${entry_path}" ]]; then
      echo "Not found: ${entry_path}" >&2
      return 1
    fi
  done <<< "${raw_paths}"

  for entry_path in "${action_paths[@]}"; do
    if rm -rf -- "${entry_path}"; then
      echo "Removed: ${entry_path}"
    else
      echo "Failed to remove: ${entry_path}" >&2
      return 1
    fi
  done
}

copy_aicodium_source() {
  local source_relative=$1
  local destination_relative=$2
  local prepared_root source_root destination_parent destination_root

  prepared_root=$(pwd -P)
  source_root="${prepared_root}/../${source_relative}"
  if [[ ! -d "${source_root}" ]]; then
    return 0
  fi

  destination_parent=$(dirname "${destination_relative}")
  destination_parent=$(cd "${destination_parent}" && pwd -P) || return
  case "${destination_parent}/" in
    "${prepared_root}/"*) ;;
    *)
      echo "AI-Codium source destination parent escapes prepared vscode: ${destination_relative}" >&2
      return 1
      ;;
  esac

  mkdir -p "${destination_relative}" || return
  destination_root=$(cd "${destination_relative}" && pwd -P) || return
  case "${destination_root}/" in
    "${prepared_root}/"*) ;;
    *)
      echo "AI-Codium source destination escapes prepared vscode: ${destination_relative}" >&2
      return 1
      ;;
  esac

  cp -Rp "${source_root}/." "${destination_root}/" || return
}

copy_aicodium_sources() {
  copy_aicodium_source \
    "src/aicodium-runtime/vscode" \
    "src/vs/platform/aicodiumRuntime" || return
  copy_aicodium_source \
    "src/aicodium-extension/vscode" \
    "extensions/aicodium" || return
}
# AICODIUM_PIPELINE_FUNCTIONS_END

# {{{ apply patches

echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "ASSETS_REPOSITORY=\"${ASSETS_REPOSITORY}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "GLOBAL_DIRNAME=\"${GLOBAL_DIRNAME}\""
echo "ORG_NAME=\"${ORG_NAME}\""
echo "TUNNEL_APP_NAME=\"${TUNNEL_APP_NAME}\""

if [[ "${DISABLE_UPDATE}" == "yes" ]]; then
  mv ../patches/00-update-disable.patch.yet ../patches/00-update-disable.patch
fi

for file in ../patches/*.json; do
  if [[ -f "${file}" ]]; then
    apply_actions "${file}"
  fi
done

for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for file in ../patches/insider/*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

if [[ -d "../patches/${OS_NAME}/" ]]; then
  for file in "../patches/${OS_NAME}/"*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

for file in ../patches/user/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done

# AICODIUM_PIPELINE_BEGIN
# Upstream actions and patches above always run before product, platform, and
# workbench AI-Codium categories.
apply_aicodium_patches
# AICODIUM_PIPELINE_END
# }}}

# AICODIUM_SOURCE_COPY_BEGIN
# Repository README files sit outside each explicit vscode/ payload boundary.
copy_aicodium_sources
# AICODIUM_SOURCE_COPY_END

set -x

# {{{ install dependencies
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

if [[ "${OS_NAME}" == "linux" ]]; then
  export VSCODE_SKIP_NODE_VERSION_CHECK=1

   if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
else
  if [[ "${CI_BUILD}" != "no" ]]; then
    clang++ --version
  fi
fi

node build/npm/preinstall.ts

mv .npmrc .npmrc.bak
cp ../npmrc .npmrc

for i in {1..5}; do # try 5 times
  if [[ "${CI_BUILD}" != "no" && "${OS_NAME}" == "osx" ]]; then
    CXX=clang++ npm ci && break
  else
    npm ci && break
  fi

  if [[ $i == 5 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."

  sleep $(( 15 * (i + 1)))
done

mv .npmrc.bak .npmrc
# }}}

# package.json
cp package.json{,.bak}

setpath "package" "version" "${RELEASE_VERSION%-insider}"

replace 's|Microsoft Corporation|VSCodium|' package.json

cp resources/server/manifest.json{,.bak}

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "resources/server/manifest" "name" "VSCodium - Insiders"
  setpath "resources/server/manifest" "short_name" "VSCodium - Insiders"
else
  setpath "resources/server/manifest" "name" "VSCodium"
  setpath "resources/server/manifest" "short_name" "VSCodium"
fi

# announcements
replace "s|\\[\\/\\* BUILTIN_ANNOUNCEMENTS \\*\\/\\]|$( tr -d '\n' < ../announcements-builtin.json )|" src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts

../undo_telemetry.sh

replace 's|Microsoft Corporation|VSCodium|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 VSCodium|' build/lib/electron.ts

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i "s/code-oss/codium-insiders/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
  fi

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://vscodium.com/img/vscodium.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|Microsoft Corporation|VSCodium Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|VSCodium|' build/win32/code.iss
fi

cd ..
