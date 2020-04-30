
import hashes, bitabs

import "../nim/compiler" / [
  ast, lineinfos
]

# Note that we must use precise hashing for floats,
# so float's ``==`` is wrong (NaN crap). Likewise we can
# save space and code when we focus on the bits of the
# involved numbers; there is no reason to store
# both 0'u64 and 0'i64 in seperate tables, the NodeKind easily
# allows us to distinguish the different number types.

type
  NumberBlob* = distinct uint64

proc hash*(x: NumberBlob): int {.borrow.}
proc `==`*(x, y: NumberBlob): bool {.borrow.}

proc toBlob*(x: float64): NumberBlob {.inline.} =
  cast[NumberBlob](x)

proc toBlob*(x: int64): NumberBlob {.inline.} =
  cast[NumberBlob](x)

proc toBlob*(x: uint64): NumberBlob {.inline.} =
  NumberBlob(x)

proc toFloat*(x: NumberBlob): float64 {.inline.} =
  cast[float64](x)

proc toInt*(x: NumberBlob): int64 {.inline.} =
  cast[int64](x)

proc toUInt*(x: NumberBlob): uint64 {.inline.} =
  uint64(x)

type
  SharedAspect* = ref object ## shared between different trees
    numbers: BiTable[NumberBlob]
    strings: BiTable[string]
    syms: seq[PSym]
    types: seq[PType]

  TinyNode* = distinct uint64  ## TNodeKind 8 bits, operand 24 bits, type ID 32 bits
  InsertionPosition* = distinct int        ## used for indexing into 'treee.instr'
  NimTree* = object
    nodes: seq[TinyNode]
    infos: seq[TLineInfo]
    sh: SharedAspect

const
  nkEnd = 255 # XXX to be added to TNodeKind as the sentinel

# XXX copy the accessors from 'packedjson' and adapt them

