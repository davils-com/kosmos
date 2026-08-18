# Build definition for all Kosmos variants. One source of truth for targets and tags, driven by
# the CI workflow (or `docker buildx bake <target>` locally).
#
# Tag scheme:
#   full     ->  <img>:<version>        <img>:<major.minor>        <img>:latest
#   <variant>->  <img>:<variant>-<ver>  <img>:<variant>-<maj.min>  <img>:<variant>-latest
#
# The plain (prefix-less) tags always point at `full`, so existing `kosmos:<ver>` references
# keep resolving to the everything-image.

variable "REGISTRY"    { default = "ghcr.io" }
variable "IMAGE"       { default = "davils-com/kosmos" }
variable "VERSION"     { default = "dev" }   # e.g. 1.1.0  (or a sha-xxxx staging tag)
variable "MAJORMINOR"  { default = "" }      # e.g. 1.1    (empty => skip this tag)
variable "PUSH_LATEST" { default = "false" } # "true" => also push the :latest alias

# Tool versions — kept here so a bump is a single, reviewable edit.
variable "GRADLE_VERSION"        { default = "9.7.0" }
variable "CMDLINE_TOOLS_VERSION" { default = "15859902_latest" }
variable "ANDROID_SDK_VERSION"   { default = "36" }
variable "BUILD_TOOLS_VERSION"   { default = "36.1.0" }

function "tags" {
  params = [prefix]
  result = distinct(concat(
    ["${REGISTRY}/${IMAGE}:${prefix}${VERSION}"],
    MAJORMINOR != "" ? ["${REGISTRY}/${IMAGE}:${prefix}${MAJORMINOR}"] : [],
    PUSH_LATEST == "true" ? ["${REGISTRY}/${IMAGE}:${prefix}latest"] : [],
  ))
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  args = {
    GRADLE_VERSION        = GRADLE_VERSION
    CMDLINE_TOOLS_VERSION = CMDLINE_TOOLS_VERSION
    ANDROID_SDK_VERSION   = ANDROID_SDK_VERSION
    BUILD_TOOLS_VERSION   = BUILD_TOOLS_VERSION
  }
}

group "default" {
  targets = ["base", "native", "android", "chrome", "full"]
}

target "base" {
  inherits = ["_common"]
  target   = "base"
  tags     = tags("base-")
}

target "native" {
  inherits = ["_common"]
  target   = "native"
  tags     = tags("native-")
}

target "android" {
  inherits = ["_common"]
  target   = "android"
  tags     = tags("android-")
}

target "chrome" {
  inherits = ["_common"]
  target   = "chrome"
  tags     = tags("chrome-")
}

target "full" {
  inherits = ["_common"]
  target   = "full"
  tags     = tags("")
}
