Require Import Effects.Effects.

(** Alternative implementation of IP using effectful combinators instead of handwritten code. *)

Definition IP :=
  forall A B, ((A -> False) -> { n : nat & B n }) ->
  { n : nat & (A -> False) -> B n }.

Effect Translate nat.
Parametricity Translate nat.
Effect Translate False.
Parametricity Translate False.
Effect Translate sigT.
Parametricity Translate sigT.
Effect Translate bool.
Parametricity Translate bool.

Scheme natᵒ_ind := Induction for natᵒ Sort Prop.
Scheme natᵒ_rect := Induction for natᵒ Sort Type.
Scheme natᴿ_ind := Induction for natᴿ Sort Prop.
Scheme natᴿ_rect := Induction for natᴿ Sort Type.

Effect Translate IP.
Parametricity Translate IP.

Effect Definition is_nat : nat -> bool using unit.
Proof.
intros E n.
induction n.
+ apply trueᵉ.
+ apply IHn.
+ apply falseᵉ.
Defined.

Effect Definition is_sigT : forall A (B : A -> Type), sigT B -> bool using unit.
Proof.
intros E A B [|]; [apply trueᵉ|apply falseᵉ].
Defined.

Arguments is_sigT {_ _} _.

Effect Definition fail : forall A, A using unit.
Proof.
intros E A; apply Err, tt.
Defined.

Arguments fail {_}.

Definition ip : IP := fun A B f =>
  let ans := f fail in
  if is_sigT ans then match ans with
  | existT _ n b =>
    if is_nat n then existT _ n (fun _ => b)
    else existT _ O fail
  end else
    existT _ O fail.

Effect Translate ip using unit.

Lemma is_nat_valid : forall n, is_natᵉ n = trueᵉ unit -> natᴿ unit n.
Proof.
intros n Hn.
induction n; cbn in *; try (constructor; intuition).
congruence.
Qed.

Lemma valid_is_nat : forall n, natᴿ unit n -> is_natᵉ n = trueᵉ unit.
Proof.
induction 1; cbn in *; intuition.
Qed.

Lemma natᴿ_hprop : forall E n (nε₀ nε₁ : @natᴿ E n), nε₀ = nε₁.
Proof.
induction nε₀; intros nε₁.
+ refine (
    match nε₁ in natᴿ _ n return
      match n return natᴿ _ n -> Prop with
      | Oᵉ _ => fun nε₁ => Oᴿ _ = nε₁
      | Sᵉ _ _ => fun _ => True
      | natᴱ _ _ => fun _ => True
      end nε₁
    with
    | Oᴿ _ => eq_refl
    | Sᴿ _ _ nε => I
    end
  ).
+ refine (
    match nε₁ in natᴿ _ n return
      match n return
        natᴿ _ n -> Prop
      with
      | Oᵉ _ => fun _ => True
      | Sᵉ _ n' => fun nε₁ => forall nε₀, (forall nε₁ : natᴿ _ n', nε₀ = nε₁) -> Sᴿ _ n' nε₀ = nε₁
      | natᴱ _ _ => fun _ => True
      end
        nε₁
    with
    | Oᴿ _ => I
    | Sᴿ _ _ nε => _
    end _ IHnε₀
  ).
  clear; intros nε₀ IH.
  f_equal.
  apply IH.
Qed.

Effect Translate projT1.
Effect Translate projT2.

Definition projT1ε {E A Aε B Bε} (p : @sigTᵒ E A B) (pε : @sigTᴿ E A Aε B Bε p) :
  Aε (projT1ᵉ E A B p) :=
  match pε in sigTᴿ _ _ _ _ _ p return Aε (projT1ᵉ E A B p)
  with
  | existTᴿ _ _ _ _ _ _ xε _ _ => xε
  end.

Definition projT2ε {E A Aε B Bε} (p : @sigTᵒ E A B) (pε : @sigTᴿ E A Aε B Bε p) :
  Bε _ (@projT1ε E A Aε B Bε p pε) (projT2ᵉ E A B p) :=
  match pε in sigTᴿ _ _ _ _ _ p return Bε _ (@projT1ε E A Aε B Bε p pε) (projT2ᵉ E A B p)
  with
  | existTᴿ _ _ _ _ _ _ _ _ yε => yε
  end.

Arguments sigTᴿ {E} {A} _ {B} _ _ : rename.

Parametricity Definition ip using unit.
Proof.
intros E A Aε B Bε p pε; cbn in *.
unfold ipᵉ; cbn.
specialize (pε (fun _ : El A => Falseᴱ unit tt)).
set (p₀ := p (fun _ : El A => Falseᴱ unit tt)) in *.
change (p (fun _ : El A => Falseᴱ unit tt)) with p₀.
clearbody p₀; clear p.
destruct p₀ as [n b|e]; cbn.
+ set (b₀ := is_natᵉ n); assert (Hn : is_natᵉ n = b₀) by reflexivity; clearbody b₀.
  destruct b₀; cbn.
  - apply is_nat_valid in Hn.
    constructor 1 with Hn.
    intros u uε.
    unshelve refine (let pε := (pε _) in _); [cbn in *|clearbody pε].
    { intros x xε; destruct (uε x xε). }
    pose (nε := projT1ε _ pε); cbn in *; replace Hn with nε by apply natᴿ_hprop.
    apply (projT2ε _ pε).
  - constructor 1 with (Oᴿ _).
    intros u uε; exfalso.
    unshelve refine (let pε := (pε _) in _); [cbn in *|clearbody pε].
    { intros x xε; destruct (uε x xε). }
    assert (nε := projT1ε _ pε); cbn in *.
    apply valid_is_nat in nε; congruence.
  - exfalso; clear - Hn.
    induction n; cbn in *; try congruence.
    apply IHn, Hn.
+ constructor 1 with (Oᴿ _).
  intros u uε; exfalso.
  unshelve refine (let pε := (pε _) in _); [cbn in *|clearbody pε].
  { intros x xε; destruct (uε x xε). }
  inversion pε.
Qed.

Print Assumptions ipᴿ.
