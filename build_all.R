r_pkgs_available <- available.packages(repos = "https://cloud.r-project.org")

r_pkgs <- r_pkgs_available |>
  transform(Package = gsub("\\.", "_", Package)) |>
  transform(nix_name = paste0("rPackages.", Package))

pkgs_to_build <- r_pkgs$nix_name

for(i in seq_along(pkgs_to_build)){
  system2(
    command = "nix-build",
    args = c("-I nixpkgs=.", "-A", pkgs_to_build[i]),
    stdout = paste0("logs/", pkgs_to_build[i], "_out.log"),
    stderr = paste0("logs/", pkgs_to_build[i], "_err.log")
  )
}
