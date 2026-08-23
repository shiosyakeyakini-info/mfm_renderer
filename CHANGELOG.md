## Unreleased

- Fix `$[rainbow ]` not matching Misskey. The color filter is now built from the
  same matrices CSS uses, so it reproduces
  `hue-rotate(0deg -> 360deg) contrast(150%) saturate(150%)` exactly. Previously
  the animation started half a turn out of phase (red rendered as cyan at 0%),
  and `colorfilter_generator`'s own scaling turned `contrast(0.5)` /
  `saturation(1.5)` into roughly `contrast(295%)` / `saturate(550%)`, which
  clipped almost every color to a fully saturated primary.
- Remove the `colorfilter_generator` dependency; it is no longer used.

## 1.0.11

- Fix `$[spin.x ]` / `$[spin.y ]` not applying the perspective projection. The
  previous code called `Matrix4.perspectiveTransform()` / `Matrix4.transform3()`,
  which only transform the passed `Vector3` and never modify the matrix itself,
  so the resulting transform was a plain orthographic rotation.

## 1.0.10

- Add `overflow` and `maxLines` options to `SimpleMfm`.
- Bump `mfm_parser` to 1.0.7.

## 1.0.9

- Bump `mfm_parser` to 1.0.6.
- Fix analyzer warning in `mfm_fn_border.dart` (remove unreachable default case).

## 1.0.8

- Add MouseRegion and Tooltip to link blocks.
- Update `dotted_border` usage and dependency bumps; related fixes and internal refactors.

## 1.0.7+1

* Hide border when `$[border.width=0 ]`

## 1.0.7

* Support `$[border]`
* Fix unconditionally nyaization in `$[ruby]`
* Fix color when give strange color

## 1.0.6

* Nyaize in `$[ruby]` text

## 1.0.5+1

* Fix did not spin in `spin`

## 1.0.5

* Add delay option in tada, jelly, twitch, shake, spin, jump, bounce, rainbow

## 1.0.4

* Fix nyaize

## 1.0.3

* Update Readme
* Fix alignment any items

## 1.0.2

* Update ReadMe

## 1.0.1

* Update ReadMe

## 1.0.0

* First release from pub.dev

## 0.0.1

* TODO: Describe initial release.
