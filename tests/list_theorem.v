Require Import Weakly.Effects.

Inductive list (A: Type): Type :=
| nil: list A
| cons: A -> list A -> list A.

Notation "x :: l" := (cons x l).

Inductive le: nat -> nat -> Prop :=
| le_O: le 0 0
| le_O_S: forall n, le 0 (S n)
| le_S: forall n m, le n m -> le (S n) (S m).

Infix "<=" := le.

Definition lt n m := S n <= m.

Infix "<" := lt.

Definition gt (n m:nat) := m < n.

Infix ">" := gt.

Effect List Translate nat list list_rect.
Effect List Translate True False not le lt eq.

Effect Definition catch_list_nil:
  forall A P Pnil Pcons Praise,
    catch_list A P Pnil Pcons Praise (nil A) = Pnil.
Proof.
  reflexivity.
Defined.

Effect Definition catch_nat_O:
  forall P PO PS Praise,
    catch_nat P PO PS Praise O = PO.
Proof.
  reflexivity.
Defined.

Effect Definition catch_nat_S:
  forall P PO PS Praise n,
    catch_nat P PO PS Praise (S n) = PS n (catch_nat P PO PS Praise n).
Proof.
  reflexivity.
Defined.

Effect Definition catch_nat_raise:
  forall P PO PS Praise e,
    catch_nat P PO PS Praise (raise _ e) = Praise e.
Proof.
  reflexivity.
Defined.

Effect Definition catch_list_cons:
  forall A P Pnil Pcons Praise a l,
    catch_list A P Pnil Pcons Praise (cons A a l) = Pcons a l (catch_list A P Pnil Pcons Praise l).
Proof.
  reflexivity.
Defined.

Effect Definition catch_list_raise:
  forall A P Pnil Pcons Praise e,
    catch_list A P Pnil Pcons Praise (raise _ e) = Praise e.
Proof.
  reflexivity.
Defined.

Definition length {A: Type} (l: list A): nat :=
  list_rect A (fun _ => nat) 0 (fun _ l n => S n) l.

Definition head {A: Type} (l: list A) e: A :=
  list_rect A (fun _ => A) (raise _ e) (fun x _ _ => x) l.

Definition tail {A: Type} (l: list A) e: list A :=
  list_rect A (fun _ => list A) (raise _ e) (fun _ l _ => l) l.

Effect List Translate length head tail.

Theorem nil_not_raise: forall A e, nil A <> raise (list A) e.
Proof.
  intros A e.
  assert
    (H: forall l',
        nil A = l' ->
        (catch_list _ (fun _ => Prop) True (fun _ _ _ => True) (fun _ => False) l')).
  - intros l' Heq. destruct Heq. rewrite catch_list_nil. exact I.
  - intros Heq. specialize (H (raise _ e) Heq). rewrite catch_list_raise in H. exact H.
Defined.

Set Printing Universes.

Theorem raise_not_leq: forall n e, n <= raise _ e -> False.
Proof.
  intros n e.
  assert (
      H: forall n',
        n <= n' ->
        catch_nat (fun _ => Prop) True (fun _ _ => True) (fun _ => False) n'
    ).
  - intros n' Hle. induction Hle.
    + rewrite catch_nat_O. exact I.
    + rewrite catch_nat_S. exact I.
    + rewrite catch_nat_S. exact I.
  - intros Hle. specialize (H (raise _ e) Hle). rewrite catch_nat_raise in H.

Theorem tail_not_empty:
  forall A e (l: list A),
    length l > 0 -> tail l <> raise _ e.
Proof.
  intros A e l Hl.














  
Effect List Translate nat list.

Definition list (A:Set) := list A.

Effect List Translate list.

Effect List Translate False True le lt gt eq not and or.
Effect List Translate eq_ind eq_sym eq_ind_r.

Scheme eqᵒ_rect := Induction for eqᵒ Sort Type.
Scheme eqᵒ_ind := Induction for eqᵒ Sort Prop.
Scheme listᵒ_rect := Induction for listᵒ Sort Type.
Scheme listᵒ_ind := Induction for listᵒ Sort Prop.
Scheme natᵒ_rect := Induction for natᵒ Sort Type.
Scheme natᵒ_ind := Induction for natᵒ Sort Prop.

Scheme leᵒ_ind := Induction for leᵒ Sort Prop.

Effect List Translate le_ind False_ind.
Effect List Translate list_rect nat_rect.

Effect Definition list_catch_prop_ : forall A (P : list A -> Prop),
       P nil -> (forall (a : A) (l : list A), P l -> P (a :: l)%list) -> (forall e, P (raise _ e)) -> forall l : list A, P l.
Proof.
  cbn; intros; induction l; auto.
Defined.

Effect Definition param_list_cons : forall (A:Set) a (l:list A), param (cons a l) -> param l.
Proof.
  cbn. intros. inversion H. auto.
Defined.

Definition list_ind : forall (A:Set) (P : list A -> Prop),
       P nil -> (forall (a : A) (l : list A), P l -> P (a :: l)%list) -> forall l : list A, param l -> P l.
Proof.
  intros A P Pnil Pcons; refine (list_catch_prop_ _ _ _ _ _).
  - intro. exact Pnil.
  - intros a l Hl param_al. exact (Pcons a l (Hl (param_list_cons _ _ _ param_al))). 
  - intros e param_e. destruct (param_correct e param_e). 
Defined. 

Definition raise@{i} {A : Set} (e:Exception@{i}) := raise A e.

Effect Translate raise. 

(* duplicated definition because of universe issue *)

Effect Definition list_catch_prop : forall A (P : list A -> Prop),
       P nil -> (forall (a : A) (l : list A), P l -> P (a :: l)%list) -> (forall e, P (raise e)) -> forall l : list A, P l.
Proof.
  cbn; intros; induction l; auto.
Defined.

Effect Definition list_catch : forall A (P : list A -> Type),
       P nil -> (forall (a : A) (l : list A), P l -> P (a :: l)%list) -> (forall e, P (raise e)) -> forall l : list A, P l.
Proof.
  cbn; intros; induction l; auto.
Defined.

Effect Definition list_catch_nil_eq : forall A (P : list A -> Type) Pnil Pcons Praise,
  list_catch A P Pnil Pcons Praise nil = Pnil. 
Proof.
  reflexivity.
Defined. 

Effect Definition list_catch_cons_eq : forall A (P : list A -> Type) Pnil Pcons Praise a l,
  list_catch A P Pnil Pcons Praise (cons a l) = Pcons a l (list_catch A P Pnil Pcons Praise l). 
Proof.
  reflexivity.
Defined. 

Effect Definition list_catch_raise_eq : forall A (P : list A -> Type) Pnil Pcons Praise e,
  list_catch A P Pnil Pcons Praise (raise e) = Praise e. 
Proof.
  reflexivity.
Defined. 

Effect Definition list_rect_raise_eq : forall A (P : list A -> Set) Pnil Pcons e,
  list_rect P Pnil Pcons (raise e) = raise e. 
Proof.
  reflexivity.
Defined.

Effect Definition nat_catch : forall (P : nat -> Type),
       P 0 -> (forall n, P n -> P (S n)) -> (forall e, P (raise e)) -> forall n, P n.
Proof.
  cbn; intros; induction n; auto.
Defined.

Effect Definition nat_catch_0_eq : forall (P : nat -> Type) P0 PS Praise,
  nat_catch P P0 PS Praise 0 = P0. 
Proof.
  reflexivity.
Defined. 

Effect Definition nat_catch_S_eq : forall (P : nat -> Type) P0 PS Praise n,
  nat_catch P P0 PS Praise (S n) = PS n (nat_catch P P0 PS Praise n). 
Proof.
  reflexivity.
Defined. 

Effect Definition nat_catch_raise_eq : forall (P : nat -> Type) P0 PS Praise e,
  nat_catch P P0 PS Praise (raise e) = Praise e. 
Proof.
  reflexivity.
Defined. 

(* Now comes the real work in the coq/rett*)

Definition length {A} (l: list A) : nat := list_rect (fun _ => nat) 0 (fun _ _ n => S n) l.

Definition head {A} (l: list A) e : A := list_rect (fun _ => A) (raise e) (fun a _ _ => a) l.

Definition tail {A} (l: list A) e : list A := list_rect (fun _ => list A) (raise e) (fun _ l _ => l) l.

Hint Unfold length.

Effect List Translate length tail head.

(* Expected theorem *)

Definition nil_not_raise: forall (A:Set) e,
    @nil A <> raise e.
Proof.
  intros A e. 
  assert (forall l', @nil A = l' -> (list_catch _ (fun _ => Prop) True (fun _ _ _ => False) (fun  _ => False) l')).
  - intros l' eq. destruct eq. rewrite list_catch_nil_eq. exact I.
  - intro eq. specialize  (H (raise e) eq). rewrite list_catch_raise_eq in H. exact H. 
Defined. 

Effect Translate nil_not_raise.

Definition cons_not_raise: forall A (l: list A) a e,
    (cons a l) <> raise e.
Proof.
  intros A l a e. 
  assert (forall l', (cons a l) = l' -> (list_catch _ (fun _ => Prop) False (fun _ _ _ => True) (fun  _ => False) l')).
  - intros l' eq. destruct eq. rewrite list_catch_cons_eq. exact I.
  - intro eq. specialize  (H (raise e) eq). rewrite list_catch_raise_eq in H. exact H. 
Defined. 

Effect Translate cons_not_raise.

(* NOT TRUE --> le_n (raise e): raise <= raise e
Definition raise_not_leq : forall (n:nat) e, n <= raise e -> False. *)


Definition O_not_raise: forall e,
    0 = raise e -> False.
Proof.
  intros e H.
  assert (
      He: forall m,
        0 = m ->
        nat_catch (fun _ => Prop) True (fun _ _ => False) (fun _ => False) m
    ).
  - intros m Heq. destruct Heq. rewrite nat_catch_0_eq. exact I.
  - specialize (He (raise e) H). rewrite nat_catch_raise_eq in He. assumption.
Defined.
Effect Translate O_not_raise.

Definition succ_not_raise: forall e n,
    S n = raise e -> False.
Proof.
  intros e n.
  assert (
      forall m,
        S n = m ->
        nat_catch (fun _ => Prop) False (fun _ _ => True) (fun _ => False) m
    ).
  - intros m Heq. destruct Heq. rewrite nat_catch_S_eq. exact I.
  - intros He. specialize (H (raise e) He). rewrite nat_catch_raise_eq in H. assumption.
Defined.
Effect Translate succ_not_raise.

(* Not valid beacause both l and n could be a raise.
Definition non_empty_list_distinct_error: forall A n e (l: list A),
    length l >= n -> l <> raise e.
Proof.
  intros A n e; refine (list_catch _ _ _ _ _); cbn.
  - intros. apply nil_not_raise.
  - intros. apply cons_not_raise.
  - intros e' H. unfold length in H. rewrite list_rect_raise_eq in H.
    compute in H. destruct (raise_not_leq  _ _ H).
Defined.
*)
(* Effect List Translate ge non_empty_list_distinct_error. *)

Definition lt_0_raise_false: forall e, 0 < raise e -> False.
Proof.
  intros e H.
  inversion H.
  - exact (succ_not_raise _ _ H1).
  - exact (succ_not_raise _ _ H0).
Defined.
Effect List Translate f_equal lt_0_raise_false.

Definition gt_raise_0_false e (H: raise e > 0): False := lt_0_raise_false e H.
Effect List Translate gt_raise_0_false.

Definition gt_0_0_false: 0 > 0 -> False.
Proof.
  refine (fun H : 0 > 0 =>
           let H1 : 0 = 0 -> False :=
               match H in (_ <= n) return (n = 0 -> False) with
               | le_n _ =>
                 fun H1 : 1 = 0 =>
                   (fun H2 : 1 = 0 =>
                      let H3 : False :=
                          eq_ind 1
                                 (fun e : nat =>
                                    nat_rect (fun _ => Prop) False (fun _ _ => True) e
                                 ) I 0 H2 in
                      False_ind False H3) H1
               | le_S _ m H1 =>
                 fun H2 : S m = 0 =>
                   (fun H3 : S m = 0 =>
                      let H4 : False :=
                          eq_ind (S m)
                                 (fun e : nat =>
                                    nat_rect (fun _ => Prop) False (fun _ _ => True) e
                                 ) I 0 H3 in
                      False_ind (1 <= m -> False) H4) H2 H1
               end in
                   H1 eq_refl).
Defined.
Effect Translate gt_0_0_false.

Definition lt_S_raise_false: forall e, 0 < S (raise e) -> False.
Proof.
  intros e.
  intros Hle.
  inversion Hle.
  - apply O_not_raise in H0. assumption.
  - apply lt_0_raise_false in H0.  assumption.
Defined.
Effect Translate lt_S_raise_false.

Definition non_empty_list_distinct_tail_error: forall A e (l: list A),
    length l > 0 -> tail l e <> raise e.
Proof.
  intros A e; refine (list_catch_prop _ _ _ _ _); cbn.
  - (* inversion 1 makes match on nat which fails *) intros Hgt _; exact (gt_0_0_false Hgt).
  - intros a l Hl Hlength eq.
    rewrite eq in Hlength. rewrite list_rect_raise_eq in Hlength.
    unfold gt in Hlength. apply lt_S_raise_false in Hlength. assumption.
  - intros e' Hlength. unfold length in Hlength. rewrite list_rect_raise_eq in Hlength.
    intros _. apply gt_raise_0_false in Hlength. assumption.
Defined.
Effect List Translate non_empty_list_distinct_tail_error.

(* Check that proving with raise is not allowed *)
Definition non_valid_theorem: forall A e (l: list A),
    length l > 0 -> tail l e = raise e := fun A e => raise e.
Fail Effect Translate non_valid_theorem.

Definition list_param_deep: forall {A} {H: ParamMod A} (l: list A), Prop :=
  fun A H => list_catch A (fun _ : list A => Prop)
                        True
                        (fun (a : A) (_ : list A) (lind : Prop) => param a /\ lind)
                        (fun _ : Exception => False).
Effect Translate list_param_deep.

Definition head_empty_list_no_error: forall A {H: ParamMod A } e (l: list A),
    length l > 0 -> list_param_deep l -> head l e <> raise e.
Proof.
  intros A A_param e. refine (list_catch_prop _ _ _ _ _).
  - (* inversion 1 makes match on nat which fails *) intros Hgt _ _; exact (gt_0_0_false Hgt).
  - intros a l Hind Hlength Hl. unfold list_param_deep in Hl.
    rewrite list_catch_cons_eq in Hl. cbn in *.
    destruct Hl as [Ha _]. intro eq. rewrite eq in Ha. apply (param_correct e Ha).
  - intros. unfold length in H. rewrite list_rect_raise_eq in H.
    intros _. apply gt_raise_0_false in H. assumption.
Defined.
(*  ## Missing in translation but derivable ##
Effect Translate head_empty_list_no_error.
*)
