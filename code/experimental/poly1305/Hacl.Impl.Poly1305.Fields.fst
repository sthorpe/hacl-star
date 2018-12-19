module Hacl.Impl.Poly1305.Fields

open FStar.HyperStack
open FStar.HyperStack.All

open Lib.IntTypes
open Lib.Buffer
open Lib.ByteBuffer

open Lib.Vec128
open Lib.Vec256

module ST = FStar.HyperStack.ST
module P = NatPrime

module F32 = Hacl.Impl.Poly1305.Field32
module F64 = Hacl.Impl.Poly1305.Field64
module F128 = Hacl.Impl.Poly1305.Field128
module F256 = Hacl.Impl.Poly1305.Field256

type field_spec =
  | M32
  | M64
  | M128
  | M256

unfold
let limb (s:field_spec) =
  match s with
  | M32 -> uint32
  | M64 -> uint64
  | M128 -> vec128
  | M256 -> vec256

unfold
let limb_zero (s:field_spec) : limb s=
  match s with
  | M32 -> u32 0
  | M64 -> u64 0
  | M128 -> vec128_zero
  | M256 -> vec256_zero

unfold
let wide (s:field_spec) =
  match s with
  | M32 -> uint64
  | M64 -> uint128
  | M128 -> vec128
  | M256 -> vec256

unfold
let nlimb (s:field_spec) : size_t =
  match s with
  | M32 -> 5ul
  | M64 -> 3ul
  | M128 -> 5ul
  | M256 -> 5ul

unfold
let blocklen (s:field_spec) : size_t =
  match s with
  | M32 -> 16ul
  | M64 -> 16ul
  | M128 -> 32ul
  | M256 -> 64ul

unfold
let nelem (s:field_spec) : size_t =
  match s with
  | M32 -> 1ul
  | M64 -> 1ul
  | M128 -> 2ul
  | M256 -> 4ul

unfold
let precomplen (s:field_spec) : size_t =
  match s with
  | M32 -> 10ul
  | M64 -> 6ul
  | M128 -> 20ul
  | M256 -> 20ul

type felem (s:field_spec) = lbuffer (limb s) (nlimb s)
type felem_wide (s:field_spec) = lbuffer (wide s) (nlimb s)
type precomp_r (s:field_spec) = lbuffer (limb s) (precomplen s)

noextract
val as_nat: #s:field_spec -> h:mem -> e:felem s -> GTot nat
let as_nat #s h e =
  match s with
  | M32 -> F32.as_nat h e
  | M64 -> F64.as_nat h e
  | M128 -> admit()
  | M256 -> admit()

noextract
val feval: #s:field_spec -> h:mem -> e:felem s -> GTot P.felem
let feval #s h e =
  match s with
  | M32 -> F32.fevalh h e
  | M64 -> admit()
  | M128 -> admit()
  | M256 -> admit()

inline_for_extraction
val create_felem:
    s:field_spec
  -> StackInline (felem s)
    (requires fun h -> True)
    (ensures  fun h0 f h1 ->
      stack_allocated f h0 h1 (Lib.Sequence.create (v (nlimb s)) (limb_zero s)) /\
      as_nat h1 f == 0)
let create_felem s =
  match s with
  | M32 -> (F32.create_felem ()) <: felem s
  | M64 -> admit(); (F64.create_felem ()) <: felem s
  | M128 -> admit(); (F128.create_felem ()) <: felem s
  | M256 -> admit(); (F256.create_felem ()) <: felem s

inline_for_extraction
val load_felem_le:
    #s:field_spec
  -> f:felem s
  -> b:lbuffer uint8 16ul
  -> Stack unit
    (requires fun h -> live h f /\ live h b)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let load_felem_le #s f b =
  match s with
  | M32 -> F32.load_felem_le f b
  | M64 -> F64.load_felem_le f b
  | M128 -> F128.load_felem_le f b
  | M256 -> F256.load_felem_le f b

inline_for_extraction
val load_felems_le:
    #s:field_spec
  -> f:felem s
  -> b:lbuffer uint8 (blocklen s)
  -> Stack unit
    (requires fun h -> live h f /\ live h b)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let load_felems_le #s f b =
  match s with
  | M32 -> F32.load_felems_le f b
  | M64 -> F64.load_felems_le f b
  | M128 -> F128.load_felems_le f b
  | M256 -> F256.load_felems_le f b

inline_for_extraction
val store_felem_le:
    #s:field_spec
  -> b:lbuffer uint8 16ul
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f /\ live h b)
    (ensures  fun h0 _ h1 -> modifies (loc b |+| loc f) h0 h1)
let store_felem_le #s b f =
  match s with
  | M32 -> admit(); F32.store_felem_le b f
  | M64 -> F64.store_felem_le b f
  | M128 -> F128.store_felem_le b f
  | M256 -> F256.store_felem_le b f

inline_for_extraction
val set_bit:
    #s:field_spec
  -> f:felem s
  -> i:size_t{size_v i < 130}
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let set_bit #s f i =
  match s with
  | M32 -> F32.set_bit f i
  | M64 -> F64.set_bit f i
  | M128 -> F128.set_bit f i
  | M256 -> F256.set_bit f i

inline_for_extraction
val set_bit128:
    #s:field_spec
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let set_bit128 #s f =
  match s with
  | M32 -> F32.set_bit128 f
  | M64 -> F64.set_bit128 f
  | M128 -> F128.set_bit128 f
  | M256 -> F256.set_bit128 f

inline_for_extraction
val set_zero:
    #s:field_spec
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 ->
      modifies (loc f) h0 h1 /\ as_nat h1 f == 0)
let set_zero #s f =
  match s with
  | M32 -> F32.set_zero f
  | M64 -> admit(); F64.set_zero f
  | M128 -> admit(); F128.set_zero f
  | M256 -> admit(); F256.set_zero f

inline_for_extraction
val copy_felem:
    #s:field_spec
  -> f:felem s
  -> f':felem s
  -> Stack unit
    (requires fun h -> live h f /\ live h f')
    (ensures  fun h0 _ h1 ->
      modifies (loc f) h0 h1 /\ as_nat h1 f == as_nat h0 f')
let copy_felem #s f f' =
  match s with
  | M32 -> F32.copy_felem f f'
  | M64 -> admit(); F64.copy_felem f f'
  | M128 -> admit(); F128.copy_felem f f'
  | M256 -> admit(); F256.copy_felem f f'

inline_for_extraction
val reduce_felem:
    #s:field_spec
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let reduce_felem #s f =
  match s with
  | M32 -> admit(); F32.reduce_felem f
  | M64 -> F64.reduce_felem f
  | M128 -> F128.reduce_felem f
  | M256 -> F256.reduce_felem f

inline_for_extraction
val load_precompute_r:
    #s:field_spec
  -> p:precomp_r s
  -> r0:uint64
  -> r1:uint64
  -> Stack unit
    (requires fun h -> live h p)
    (ensures  fun h0 _ h1 -> modifies (loc p) h0 h1)
let load_precompute_r #s p r0 r1 =
  match s with
  | M32 -> admit(); F32.load_precompute_r p r0 r1
  | M64 -> F64.load_precompute_r p r0 r1
  | M128 -> F128.load_precompute_r p r0 r1
  | M256 -> F256.load_precompute_r p r0 r1

inline_for_extraction
val fmul_r:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> precomp:precomp_r s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h precomp)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1)
let fmul_r #s out f1 precomp =
  match s with
  | M32 -> admit(); F32.fmul_r out f1 precomp
  | M64 -> F64.fmul_r out f1 precomp
  | M128 -> F128.fmul_r out f1 precomp
  | M256 -> F256.fmul_r out f1 precomp

inline_for_extraction
val fadd_mul_r:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> precomp:precomp_r s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h precomp)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1)
let fadd_mul_r #s out f1 precomp =
  match s with
  | M32 -> admit(); F32.fadd_mul_r out f1 precomp
  | M64 -> F64.fadd_mul_r out f1 precomp
  | M128 -> F128.fadd_mul_r out f1 precomp
  | M256 -> F256.fadd_mul_r out f1 precomp

inline_for_extraction
val fmul_rn:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> precomp:precomp_r s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h precomp)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1)
let fmul_rn #s out f1 precomp =
  match s with
  | M32 -> admit(); F32.fmul_rn out f1 precomp
  | M64 -> F64.fmul_rn out f1 precomp
  | M128 -> F128.fmul_rn out f1 precomp
  | M256 -> F256.fmul_rn out f1 precomp

inline_for_extraction
val fmul_rn_normalize:
    #s:field_spec
  -> out:felem s
  -> precomp:precomp_r s
  -> Stack unit
    (requires fun h -> live h out /\ live h precomp)
    (ensures  fun h0 _ h1 -> modifies (loc out |+| loc precomp) h0 h1)
let fmul_rn_normalize #s out precomp =
  match s with
  | M32 -> admit(); F32.fmul_rn_normalize out precomp
  | M64 -> F64.fmul_rn_normalize out precomp
  | M128 -> F128.fmul_rn_normalize out precomp
  | M256 -> F256.fmul_rn_normalize out precomp

inline_for_extraction
val fadd:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> f2:felem s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h f2)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1)
let fadd #s out f1 f2=
  match s with
  | M32 -> admit(); F32.fadd out f1 f2
  | M64 -> admit(); F64.fadd out f1 f2
  | M128 -> F128.fadd out f1 f2
  | M256 -> F256.fadd out f1 f2
