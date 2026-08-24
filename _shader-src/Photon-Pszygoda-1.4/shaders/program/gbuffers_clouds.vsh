/*
--------------------------------------------------------------------------------

  Photon-Pszygoda dedicated vanilla Fancy-cloud vertex pass.

  Iris otherwise falls back to gbuffers_textured, which mixes clouds with
  particles and world-border geometry and applies Photon's material lighting a
  second time. Keep this wrapper separate so cloud equalisation cannot affect any
  other translucent draw call.

--------------------------------------------------------------------------------
*/

#include "/program/gbuffers_all_translucent.vsh"
