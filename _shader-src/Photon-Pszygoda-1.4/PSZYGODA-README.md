# Photon Pszygoda 1.4

This is a modpack derivative of Photon 1.3b for Pszygoda Portals.

Changes from upstream:

- Iris `clouds=fancy` is enabled.
- Photon's no-op `gbuffers_clouds` programs are omitted so Iris routes native
  Minecraft cloud geometry through `gbuffers_textured`.
- Photon's volumetric cloud layers are disabled by default to avoid drawing
  two cloud systems at once.
- The vanilla square Minecraft sun and phase-aware moon textures are enabled
  by default; Photon's realistic procedural celestial disks are disabled while
  their lighting remains active.
- TAA stays disabled by default because Immersive Portals cannot render it
  correctly while a portal is visible. Motion blur was already disabled.
- `krawedz:podroz` uses a dedicated Iris dimension mapping and Overworld
  wrappers, so the other dimensions retain upstream Photon rendering.
- The final 400-block transition follows the exact Iris camera X coordinate
  and blends the atmospheric sky toward the Pszygoda gold palette before
  cloud lighting. This also follows Flashback freecam during replay playback.

The release ZIP is built deterministically from this directory by
`scripts/build-photon.ps1`; `worldKrawedz` wrappers are generated from
`shaders/world0` and are intentionally not stored twice in this source tree.

Photon's original LICENSE is included unchanged. This derivative is
redistributed only as part of the Pszygoda Portals modpack.
