open Prims
let fail_exp lid t =
  (FStar_Syntax_Syntax.mk
     (FStar_Syntax_Syntax.Tm_app
        (let _0_621 =
           FStar_Syntax_Syntax.fvar FStar_Syntax_Const.failwith_lid
             FStar_Syntax_Syntax.Delta_constant None in
         let _0_620 =
           let _0_619 = FStar_Syntax_Syntax.iarg t in
           let _0_618 =
             let _0_617 =
               let _0_616 =
                 (FStar_Syntax_Syntax.mk
                    (FStar_Syntax_Syntax.Tm_constant
                       (FStar_Const.Const_string
                          (let _0_615 =
                             FStar_Bytes.string_as_unicode_bytes
                               (let _0_614 =
                                  FStar_Syntax_Print.lid_to_string lid in
                                Prims.strcat "Not yet implemented:" _0_614) in
                           (_0_615, FStar_Range.dummyRange))))) None
                   FStar_Range.dummyRange in
               FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _0_616 in
             [_0_617] in
           _0_619 :: _0_618 in
         (_0_621, _0_620)))) None FStar_Range.dummyRange
let mangle_projector_lid: FStar_Ident.lident -> FStar_Ident.lident =
  fun x  -> x
let lident_as_mlsymbol: FStar_Ident.lident -> Prims.string =
  fun id  -> (id.FStar_Ident.ident).FStar_Ident.idText
let binders_as_mlty_binders env bs =
  FStar_Util.fold_map
    (fun env  ->
       fun uu____70  ->
         match uu____70 with
         | (bv,uu____78) ->
             let _0_624 =
               let _0_622 =
                 Some
                   (FStar_Extraction_ML_Syntax.MLTY_Var
                      (FStar_Extraction_ML_UEnv.bv_as_ml_tyvar bv)) in
               FStar_Extraction_ML_UEnv.extend_ty env bv _0_622 in
             let _0_623 = FStar_Extraction_ML_UEnv.bv_as_ml_tyvar bv in
             (_0_624, _0_623)) env bs
let extract_typ_abbrev:
  FStar_Extraction_ML_UEnv.env ->
    FStar_Syntax_Syntax.fv ->
      FStar_Syntax_Syntax.qualifier Prims.list ->
        FStar_Syntax_Syntax.term ->
          (FStar_Extraction_ML_UEnv.env* FStar_Extraction_ML_Syntax.mlmodule1
            Prims.list)
  =
  fun env  ->
    fun fv  ->
      fun quals  ->
        fun def  ->
          let lid = (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
          let def =
            let _0_626 =
              let _0_625 = FStar_Syntax_Subst.compress def in
              FStar_All.pipe_right _0_625 FStar_Syntax_Util.unmeta in
            FStar_All.pipe_right _0_626 FStar_Syntax_Util.un_uinst in
          let def =
            match def.FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_abs uu____105 ->
                FStar_Extraction_ML_Term.normalize_abs def
            | uu____120 -> def in
          let uu____121 =
            match def.FStar_Syntax_Syntax.n with
            | FStar_Syntax_Syntax.Tm_abs (bs,body,uu____128) ->
                FStar_Syntax_Subst.open_term bs body
            | uu____151 -> ([], def) in
          match uu____121 with
          | (bs,body) ->
              let assumed =
                FStar_Util.for_some
                  (fun uu___144_163  ->
                     match uu___144_163 with
                     | FStar_Syntax_Syntax.Assumption  -> true
                     | uu____164 -> false) quals in
              let uu____165 = binders_as_mlty_binders env bs in
              (match uu____165 with
               | (env,ml_bs) ->
                   let body =
                     let _0_627 =
                       FStar_Extraction_ML_Term.term_as_mlty env body in
                     FStar_All.pipe_right _0_627
                       (FStar_Extraction_ML_Util.eraseTypeDeep
                          (FStar_Extraction_ML_Util.udelta_unfold env)) in
                   let mangled_projector =
                     let uu____185 =
                       FStar_All.pipe_right quals
                         (FStar_Util.for_some
                            (fun uu___145_187  ->
                               match uu___145_187 with
                               | FStar_Syntax_Syntax.Projector uu____188 ->
                                   true
                               | uu____191 -> false)) in
                     if uu____185
                     then
                       let mname = mangle_projector_lid lid in
                       Some ((mname.FStar_Ident.ident).FStar_Ident.idText)
                     else None in
                   let td =
                     let _0_629 =
                       let _0_628 = lident_as_mlsymbol lid in
                       (assumed, _0_628, mangled_projector, ml_bs,
                         (Some (FStar_Extraction_ML_Syntax.MLTD_Abbrev body))) in
                     [_0_629] in
                   let def =
                     let _0_630 =
                       FStar_Extraction_ML_Syntax.MLM_Loc
                         (FStar_Extraction_ML_Util.mlloc_of_range
                            (FStar_Ident.range_of_lid lid)) in
                     [_0_630; FStar_Extraction_ML_Syntax.MLM_Ty td] in
                   let env =
                     let uu____235 =
                       FStar_All.pipe_right quals
                         (FStar_Util.for_some
                            (fun uu___146_237  ->
                               match uu___146_237 with
                               | FStar_Syntax_Syntax.Assumption 
                                 |FStar_Syntax_Syntax.New  -> true
                               | uu____238 -> false)) in
                     if uu____235
                     then env
                     else FStar_Extraction_ML_UEnv.extend_tydef env fv td in
                   (env, def))
type data_constructor =
  {
  dname: FStar_Ident.lident;
  dtyp: FStar_Syntax_Syntax.typ;}
type inductive_family =
  {
  iname: FStar_Ident.lident;
  iparams: FStar_Syntax_Syntax.binders;
  ityp: FStar_Syntax_Syntax.term;
  idatas: data_constructor Prims.list;
  iquals: FStar_Syntax_Syntax.qualifier Prims.list;}
let print_ifamily: inductive_family -> Prims.unit =
  fun i  ->
    let _0_638 = FStar_Syntax_Print.lid_to_string i.iname in
    let _0_637 = FStar_Syntax_Print.binders_to_string " " i.iparams in
    let _0_636 = FStar_Syntax_Print.term_to_string i.ityp in
    let _0_635 =
      let _0_634 =
        FStar_All.pipe_right i.idatas
          (FStar_List.map
             (fun d  ->
                let _0_633 = FStar_Syntax_Print.lid_to_string d.dname in
                let _0_632 =
                  let _0_631 = FStar_Syntax_Print.term_to_string d.dtyp in
                  Prims.strcat " : " _0_631 in
                Prims.strcat _0_633 _0_632)) in
      FStar_All.pipe_right _0_634 (FStar_String.concat "\n\t\t") in
    FStar_Util.print4 "\n\t%s %s : %s { %s }\n" _0_638 _0_637 _0_636 _0_635
let bundle_as_inductive_families env ses quals =
  FStar_All.pipe_right ses
    (FStar_List.collect
       (fun uu___148_327  ->
          match uu___148_327 with
          | FStar_Syntax_Syntax.Sig_inductive_typ
              (l,_us,bs,t,_mut_i,datas,quals,r) ->
              let uu____343 = FStar_Syntax_Subst.open_term bs t in
              (match uu____343 with
               | (bs,t) ->
                   let datas =
                     FStar_All.pipe_right ses
                       (FStar_List.collect
                          (fun uu___147_353  ->
                             match uu___147_353 with
                             | FStar_Syntax_Syntax.Sig_datacon
                                 (d,uu____356,t,l',nparams,uu____360,uu____361,uu____362)
                                 when FStar_Ident.lid_equals l l' ->
                                 let uu____367 =
                                   FStar_Syntax_Util.arrow_formals t in
                                 (match uu____367 with
                                  | (bs',body) ->
                                      let uu____388 =
                                        FStar_Util.first_N
                                          (FStar_List.length bs) bs' in
                                      (match uu____388 with
                                       | (bs_params,rest) ->
                                           let subst =
                                             FStar_List.map2
                                               (fun uu____424  ->
                                                  fun uu____425  ->
                                                    match (uu____424,
                                                            uu____425)
                                                    with
                                                    | ((b',uu____435),
                                                       (b,uu____437)) ->
                                                        FStar_Syntax_Syntax.NT
                                                          (let _0_639 =
                                                             FStar_Syntax_Syntax.bv_to_name
                                                               b in
                                                           (b', _0_639)))
                                               bs_params bs in
                                           let t =
                                             let _0_641 =
                                               let _0_640 =
                                                 FStar_Syntax_Syntax.mk_Total
                                                   body in
                                               FStar_Syntax_Util.arrow rest
                                                 _0_640 in
                                             FStar_All.pipe_right _0_641
                                               (FStar_Syntax_Subst.subst
                                                  subst) in
                                           [{ dname = d; dtyp = t }]))
                             | uu____445 -> [])) in
                   [{
                      iname = l;
                      iparams = bs;
                      ityp = t;
                      idatas = datas;
                      iquals = quals
                    }])
          | uu____446 -> []))
type env_t = FStar_Extraction_ML_UEnv.env
let extract_bundle:
  env_t ->
    FStar_Syntax_Syntax.sigelt ->
      (env_t* FStar_Extraction_ML_Syntax.mlmodule1 Prims.list)
  =
  fun env  ->
    fun se  ->
      let extract_ctor ml_tyvars env ctor =
        let mlt =
          let _0_642 = FStar_Extraction_ML_Term.term_as_mlty env ctor.dtyp in
          FStar_Extraction_ML_Util.eraseTypeDeep
            (FStar_Extraction_ML_Util.udelta_unfold env) _0_642 in
        let tys = (ml_tyvars, mlt) in
        let fvv = FStar_Extraction_ML_UEnv.mkFvvar ctor.dname ctor.dtyp in
        let _0_646 =
          FStar_Extraction_ML_UEnv.extend_fv env fvv tys false false in
        let _0_645 =
          let _0_644 = lident_as_mlsymbol ctor.dname in
          let _0_643 = FStar_Extraction_ML_Util.argTypes mlt in
          (_0_644, _0_643) in
        (_0_646, _0_645) in
      let extract_one_family env ind =
        let uu____516 = binders_as_mlty_binders env ind.iparams in
        match uu____516 with
        | (env,vars) ->
            let uu____542 =
              FStar_All.pipe_right ind.idatas
                (FStar_Util.fold_map (extract_ctor vars) env) in
            (match uu____542 with
             | (env,ctors) ->
                 let uu____581 = FStar_Syntax_Util.arrow_formals ind.ityp in
                 (match uu____581 with
                  | (indices,uu____602) ->
                      let ml_params =
                        let _0_649 =
                          FStar_All.pipe_right indices
                            (FStar_List.mapi
                               (fun i  ->
                                  fun uu____630  ->
                                    let _0_648 =
                                      let _0_647 = FStar_Util.string_of_int i in
                                      Prims.strcat "'dummyV" _0_647 in
                                    (_0_648, (Prims.parse_int "0")))) in
                        FStar_List.append vars _0_649 in
                      let tbody =
                        let uu____634 =
                          FStar_Util.find_opt
                            (fun uu___149_636  ->
                               match uu___149_636 with
                               | FStar_Syntax_Syntax.RecordType uu____637 ->
                                   true
                               | uu____642 -> false) ind.iquals in
                        match uu____634 with
                        | Some (FStar_Syntax_Syntax.RecordType (ns,ids)) ->
                            let uu____649 = FStar_List.hd ctors in
                            (match uu____649 with
                             | (uu____656,c_ty) ->
                                 let fields =
                                   FStar_List.map2
                                     (fun id  ->
                                        fun ty  ->
                                          let lid =
                                            FStar_Ident.lid_of_ids
                                              (FStar_List.append ns [id]) in
                                          let _0_650 = lident_as_mlsymbol lid in
                                          (_0_650, ty)) ids c_ty in
                                 FStar_Extraction_ML_Syntax.MLTD_Record
                                   fields)
                        | uu____670 ->
                            FStar_Extraction_ML_Syntax.MLTD_DType ctors in
                      let _0_652 =
                        let _0_651 = lident_as_mlsymbol ind.iname in
                        (false, _0_651, None, ml_params, (Some tbody)) in
                      (env, _0_652))) in
      match se with
      | FStar_Syntax_Syntax.Sig_bundle
          ((FStar_Syntax_Syntax.Sig_datacon
           (l,uu____691,t,uu____693,uu____694,uu____695,uu____696,uu____697))::[],(FStar_Syntax_Syntax.ExceptionConstructor
           )::[],uu____698,r)
          ->
          let uu____708 = extract_ctor [] env { dname = l; dtyp = t } in
          (match uu____708 with
           | (env,ctor) -> (env, [FStar_Extraction_ML_Syntax.MLM_Exn ctor]))
      | FStar_Syntax_Syntax.Sig_bundle (ses,quals,uu____730,r) ->
          let ifams = bundle_as_inductive_families env ses quals in
          let uu____741 = FStar_Util.fold_map extract_one_family env ifams in
          (match uu____741 with
           | (env,td) -> (env, [FStar_Extraction_ML_Syntax.MLM_Ty td]))
      | uu____793 -> failwith "Unexpected signature element"
let rec extract_sig:
  env_t ->
    FStar_Syntax_Syntax.sigelt ->
      (env_t* FStar_Extraction_ML_Syntax.mlmodule1 Prims.list)
  =
  fun g  ->
    fun se  ->
      FStar_Extraction_ML_UEnv.debug g
        (fun u  ->
           let _0_653 = FStar_Syntax_Print.sigelt_to_string se in
           FStar_Util.print1 ">>>> extract_sig %s \n" _0_653);
      (match se with
       | FStar_Syntax_Syntax.Sig_bundle _
         |FStar_Syntax_Syntax.Sig_inductive_typ _
          |FStar_Syntax_Syntax.Sig_datacon _ -> extract_bundle g se
       | FStar_Syntax_Syntax.Sig_new_effect (ed,uu____818) when
           FStar_All.pipe_right ed.FStar_Syntax_Syntax.qualifiers
             (FStar_List.contains FStar_Syntax_Syntax.Reifiable)
           ->
           let extend_env g lid ml_name tm tysc =
             let mangled_name = Prims.snd ml_name in
             let g =
               let _0_654 =
                 FStar_Syntax_Syntax.lid_as_fv lid
                   FStar_Syntax_Syntax.Delta_equational None in
               FStar_Extraction_ML_UEnv.extend_fv' g _0_654 ml_name tysc
                 false false in
             let lb =
               {
                 FStar_Extraction_ML_Syntax.mllb_name =
                   (mangled_name, (Prims.parse_int "0"));
                 FStar_Extraction_ML_Syntax.mllb_tysc = None;
                 FStar_Extraction_ML_Syntax.mllb_add_unit = false;
                 FStar_Extraction_ML_Syntax.mllb_def = tm;
                 FStar_Extraction_ML_Syntax.print_typ = false
               } in
             (g,
               (FStar_Extraction_ML_Syntax.MLM_Let
                  (FStar_Extraction_ML_Syntax.NonRec, [], [lb]))) in
           let rec extract_fv tm =
             let uu____856 =
               (FStar_Syntax_Subst.compress tm).FStar_Syntax_Syntax.n in
             match uu____856 with
             | FStar_Syntax_Syntax.Tm_uinst (tm,uu____860) -> extract_fv tm
             | FStar_Syntax_Syntax.Tm_fvar fv ->
                 let mlp =
                   FStar_Extraction_ML_Syntax.mlpath_of_lident
                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                 let uu____871 =
                   let _0_655 = FStar_Extraction_ML_UEnv.lookup_fv g fv in
                   FStar_All.pipe_left FStar_Util.right _0_655 in
                 (match uu____871 with
                  | (uu____892,tysc,uu____894) ->
                      let _0_656 =
                        FStar_All.pipe_left
                          (FStar_Extraction_ML_Syntax.with_ty
                             FStar_Extraction_ML_Syntax.MLTY_Top)
                          (FStar_Extraction_ML_Syntax.MLE_Name mlp) in
                      (_0_656, tysc))
             | uu____895 -> failwith "Not an fv" in
           let extract_action g a =
             let uu____907 = extract_fv a.FStar_Syntax_Syntax.action_defn in
             match uu____907 with
             | (a_tm,ty_sc) ->
                 let uu____914 = FStar_Extraction_ML_UEnv.action_name ed a in
                 (match uu____914 with
                  | (a_nm,a_lid) -> extend_env g a_lid a_nm a_tm ty_sc) in
           let uu____921 =
             let uu____924 =
               extract_fv (Prims.snd ed.FStar_Syntax_Syntax.return_repr) in
             match uu____924 with
             | (return_tm,ty_sc) ->
                 let uu____932 =
                   FStar_Extraction_ML_UEnv.monad_op_name ed "return" in
                 (match uu____932 with
                  | (return_nm,return_lid) ->
                      extend_env g return_lid return_nm return_tm ty_sc) in
           (match uu____921 with
            | (g,return_decl) ->
                let uu____944 =
                  let uu____947 =
                    extract_fv (Prims.snd ed.FStar_Syntax_Syntax.bind_repr) in
                  match uu____947 with
                  | (bind_tm,ty_sc) ->
                      let uu____955 =
                        FStar_Extraction_ML_UEnv.monad_op_name ed "bind" in
                      (match uu____955 with
                       | (bind_nm,bind_lid) ->
                           extend_env g bind_lid bind_nm bind_tm ty_sc) in
                (match uu____944 with
                 | (g,bind_decl) ->
                     let uu____967 =
                       FStar_Util.fold_map extract_action g
                         ed.FStar_Syntax_Syntax.actions in
                     (match uu____967 with
                      | (g,actions) ->
                          (g,
                            (FStar_List.append [return_decl; bind_decl]
                               actions)))))
       | FStar_Syntax_Syntax.Sig_new_effect uu____979 -> (g, [])
       | FStar_Syntax_Syntax.Sig_declare_typ
           (lid,uu____984,t,quals,uu____987) when
           FStar_Extraction_ML_Term.is_arity g t ->
           let uu____990 =
             let _0_657 =
               FStar_All.pipe_right quals
                 (FStar_Util.for_some
                    (fun uu___150_992  ->
                       match uu___150_992 with
                       | FStar_Syntax_Syntax.Assumption  -> true
                       | uu____993 -> false)) in
             FStar_All.pipe_right _0_657 Prims.op_Negation in
           if uu____990
           then (g, [])
           else
             (let uu____999 = FStar_Syntax_Util.arrow_formals t in
              match uu____999 with
              | (bs,uu____1011) ->
                  let fv =
                    FStar_Syntax_Syntax.lid_as_fv lid
                      FStar_Syntax_Syntax.Delta_constant None in
                  let _0_658 =
                    FStar_Syntax_Util.abs bs FStar_TypeChecker_Common.t_unit
                      None in
                  extract_typ_abbrev g fv quals _0_658)
       | FStar_Syntax_Syntax.Sig_let
           ((false ,lb::[]),uu____1029,uu____1030,quals,uu____1032) when
           FStar_Extraction_ML_Term.is_arity g lb.FStar_Syntax_Syntax.lbtyp
           ->
           let _0_659 = FStar_Util.right lb.FStar_Syntax_Syntax.lbname in
           extract_typ_abbrev g _0_659 quals lb.FStar_Syntax_Syntax.lbdef
       | FStar_Syntax_Syntax.Sig_let (lbs,r,uu____1045,quals,attrs) ->
           let elet =
             (FStar_Syntax_Syntax.mk
                (FStar_Syntax_Syntax.Tm_let
                   (lbs, FStar_Syntax_Const.exp_false_bool))) None r in
           let uu____1065 = FStar_Extraction_ML_Term.term_as_mlexpr g elet in
           (match uu____1065 with
            | (ml_let,uu____1073,uu____1074) ->
                (match ml_let.FStar_Extraction_ML_Syntax.expr with
                 | FStar_Extraction_ML_Syntax.MLE_Let
                     ((flavor,uu____1079,bindings),uu____1081) ->
                     let uu____1088 =
                       FStar_List.fold_left2
                         (fun uu____1095  ->
                            fun ml_lb  ->
                              fun uu____1097  ->
                                match (uu____1095, uu____1097) with
                                | ((env,ml_lbs),{
                                                  FStar_Syntax_Syntax.lbname
                                                    = lbname;
                                                  FStar_Syntax_Syntax.lbunivs
                                                    = uu____1110;
                                                  FStar_Syntax_Syntax.lbtyp =
                                                    t;
                                                  FStar_Syntax_Syntax.lbeff =
                                                    uu____1112;
                                                  FStar_Syntax_Syntax.lbdef =
                                                    uu____1113;_})
                                    ->
                                    let lb_lid =
                                      ((FStar_Util.right lbname).FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                    let uu____1131 =
                                      let uu____1134 =
                                        FStar_All.pipe_right quals
                                          (FStar_Util.for_some
                                             (fun uu___151_1136  ->
                                                match uu___151_1136 with
                                                | FStar_Syntax_Syntax.Projector
                                                    uu____1137 -> true
                                                | uu____1140 -> false)) in
                                      if uu____1134
                                      then
                                        let mname =
                                          let _0_660 =
                                            mangle_projector_lid lb_lid in
                                          FStar_All.pipe_right _0_660
                                            FStar_Extraction_ML_Syntax.mlpath_of_lident in
                                        let env =
                                          let _0_662 =
                                            FStar_Util.right lbname in
                                          let _0_661 =
                                            FStar_Util.must
                                              ml_lb.FStar_Extraction_ML_Syntax.mllb_tysc in
                                          FStar_Extraction_ML_UEnv.extend_fv'
                                            env _0_662 mname _0_661
                                            ml_lb.FStar_Extraction_ML_Syntax.mllb_add_unit
                                            false in
                                        (env,
                                          (let uu___156_1145 = ml_lb in
                                           {
                                             FStar_Extraction_ML_Syntax.mllb_name
                                               =
                                               ((Prims.snd mname),
                                                 (Prims.parse_int "0"));
                                             FStar_Extraction_ML_Syntax.mllb_tysc
                                               =
                                               (uu___156_1145.FStar_Extraction_ML_Syntax.mllb_tysc);
                                             FStar_Extraction_ML_Syntax.mllb_add_unit
                                               =
                                               (uu___156_1145.FStar_Extraction_ML_Syntax.mllb_add_unit);
                                             FStar_Extraction_ML_Syntax.mllb_def
                                               =
                                               (uu___156_1145.FStar_Extraction_ML_Syntax.mllb_def);
                                             FStar_Extraction_ML_Syntax.print_typ
                                               =
                                               (uu___156_1145.FStar_Extraction_ML_Syntax.print_typ)
                                           }))
                                      else
                                        (let _0_665 =
                                           let _0_664 =
                                             let _0_663 =
                                               FStar_Util.must
                                                 ml_lb.FStar_Extraction_ML_Syntax.mllb_tysc in
                                             FStar_Extraction_ML_UEnv.extend_lb
                                               env lbname t _0_663
                                               ml_lb.FStar_Extraction_ML_Syntax.mllb_add_unit
                                               false in
                                           FStar_All.pipe_left Prims.fst
                                             _0_664 in
                                         (_0_665, ml_lb)) in
                                    (match uu____1131 with
                                     | (g,ml_lb) -> (g, (ml_lb :: ml_lbs))))
                         (g, []) bindings (Prims.snd lbs) in
                     (match uu____1088 with
                      | (g,ml_lbs') ->
                          let flags =
                            FStar_List.choose
                              (fun uu___152_1167  ->
                                 match uu___152_1167 with
                                 | FStar_Syntax_Syntax.Assumption  ->
                                     Some FStar_Extraction_ML_Syntax.Assumed
                                 | FStar_Syntax_Syntax.Private  ->
                                     Some FStar_Extraction_ML_Syntax.Private
                                 | FStar_Syntax_Syntax.NoExtract  ->
                                     Some
                                       FStar_Extraction_ML_Syntax.NoExtract
                                 | uu____1169 -> None) quals in
                          let flags' =
                            FStar_List.choose
                              (fun uu___153_1174  ->
                                 match uu___153_1174 with
                                 | {
                                     FStar_Syntax_Syntax.n =
                                       FStar_Syntax_Syntax.Tm_constant
                                       (FStar_Const.Const_string
                                       (data,uu____1179));
                                     FStar_Syntax_Syntax.tk = uu____1180;
                                     FStar_Syntax_Syntax.pos = uu____1181;
                                     FStar_Syntax_Syntax.vars = uu____1182;_}
                                     ->
                                     Some
                                       (FStar_Extraction_ML_Syntax.Attribute
                                          (FStar_Util.string_of_unicode data))
                                 | uu____1187 ->
                                     (FStar_Util.print_warning
                                        "Warning: unrecognized, non-string attribute, bother protz for a better error message";
                                      None)) attrs in
                          let _0_667 =
                            let _0_666 =
                              FStar_Extraction_ML_Syntax.MLM_Loc
                                (FStar_Extraction_ML_Util.mlloc_of_range r) in
                            [_0_666;
                            FStar_Extraction_ML_Syntax.MLM_Let
                              (flavor, (FStar_List.append flags flags'),
                                (FStar_List.rev ml_lbs'))] in
                          (g, _0_667))
                 | uu____1194 ->
                     failwith
                       (let _0_668 =
                          FStar_Extraction_ML_Code.string_of_mlexpr
                            g.FStar_Extraction_ML_UEnv.currentModule ml_let in
                        FStar_Util.format1
                          "Impossible: Translated a let to a non-let: %s"
                          _0_668)))
       | FStar_Syntax_Syntax.Sig_declare_typ (lid,uu____1199,t,quals,r) ->
           let uu____1205 =
             FStar_All.pipe_right quals
               (FStar_List.contains FStar_Syntax_Syntax.Assumption) in
           if uu____1205
           then
             let always_fail =
               let imp =
                 let uu____1214 = FStar_Syntax_Util.arrow_formals t in
                 match uu____1214 with
                 | ([],t) -> fail_exp lid t
                 | (bs,t) ->
                     let _0_669 = fail_exp lid t in
                     FStar_Syntax_Util.abs bs _0_669 None in
               FStar_Syntax_Syntax.Sig_let
                 (let _0_673 =
                    let _0_672 =
                      let _0_671 =
                        let _0_670 =
                          FStar_Util.Inr
                            (FStar_Syntax_Syntax.lid_as_fv lid
                               FStar_Syntax_Syntax.Delta_constant None) in
                        {
                          FStar_Syntax_Syntax.lbname = _0_670;
                          FStar_Syntax_Syntax.lbunivs = [];
                          FStar_Syntax_Syntax.lbtyp = t;
                          FStar_Syntax_Syntax.lbeff =
                            FStar_Syntax_Const.effect_ML_lid;
                          FStar_Syntax_Syntax.lbdef = imp
                        } in
                      [_0_671] in
                    (false, _0_672) in
                  (_0_673, r, [], quals, [])) in
             let uu____1258 = extract_sig g always_fail in
             (match uu____1258 with
              | (g,mlm) ->
                  let uu____1269 =
                    FStar_Util.find_map quals
                      (fun uu___154_1271  ->
                         match uu___154_1271 with
                         | FStar_Syntax_Syntax.Discriminator l -> Some l
                         | uu____1274 -> None) in
                  (match uu____1269 with
                   | Some l ->
                       let _0_677 =
                         let _0_676 =
                           FStar_Extraction_ML_Syntax.MLM_Loc
                             (FStar_Extraction_ML_Util.mlloc_of_range r) in
                         let _0_675 =
                           let _0_674 =
                             FStar_Extraction_ML_Term.ind_discriminator_body
                               g lid l in
                           [_0_674] in
                         _0_676 :: _0_675 in
                       (g, _0_677)
                   | uu____1280 ->
                       let uu____1282 =
                         FStar_Util.find_map quals
                           (fun uu___155_1284  ->
                              match uu___155_1284 with
                              | FStar_Syntax_Syntax.Projector (l,uu____1287)
                                  -> Some l
                              | uu____1288 -> None) in
                       (match uu____1282 with
                        | Some uu____1292 -> (g, [])
                        | uu____1294 -> (g, mlm))))
           else (g, [])
       | FStar_Syntax_Syntax.Sig_main (e,r) ->
           let uu____1301 = FStar_Extraction_ML_Term.term_as_mlexpr g e in
           (match uu____1301 with
            | (ml_main,uu____1309,uu____1310) ->
                let _0_679 =
                  let _0_678 =
                    FStar_Extraction_ML_Syntax.MLM_Loc
                      (FStar_Extraction_ML_Util.mlloc_of_range r) in
                  [_0_678; FStar_Extraction_ML_Syntax.MLM_Top ml_main] in
                (g, _0_679))
       | FStar_Syntax_Syntax.Sig_new_effect_for_free uu____1312 ->
           failwith "impossible -- removed by tc.fs"
       | FStar_Syntax_Syntax.Sig_assume _
         |FStar_Syntax_Syntax.Sig_sub_effect _
          |FStar_Syntax_Syntax.Sig_effect_abbrev _ -> (g, [])
       | FStar_Syntax_Syntax.Sig_pragma (p,uu____1323) ->
           (if p = FStar_Syntax_Syntax.LightOff
            then FStar_Options.set_ml_ish ()
            else ();
            (g, [])))
let extract_iface:
  FStar_Extraction_ML_UEnv.env -> FStar_Syntax_Syntax.modul -> env_t =
  fun g  ->
    fun m  ->
      let _0_680 =
        FStar_Util.fold_map extract_sig g m.FStar_Syntax_Syntax.declarations in
      FStar_All.pipe_right _0_680 Prims.fst
let extract:
  FStar_Extraction_ML_UEnv.env ->
    FStar_Syntax_Syntax.modul ->
      (FStar_Extraction_ML_UEnv.env* FStar_Extraction_ML_Syntax.mllib
        Prims.list)
  =
  fun g  ->
    fun m  ->
      FStar_Syntax_Syntax.reset_gensym ();
      (let uu____1353 = FStar_Options.restore_cmd_line_options true in
       let name =
         FStar_Extraction_ML_Syntax.mlpath_of_lident
           m.FStar_Syntax_Syntax.name in
       let g =
         let uu___157_1356 = g in
         {
           FStar_Extraction_ML_UEnv.tcenv =
             (uu___157_1356.FStar_Extraction_ML_UEnv.tcenv);
           FStar_Extraction_ML_UEnv.gamma =
             (uu___157_1356.FStar_Extraction_ML_UEnv.gamma);
           FStar_Extraction_ML_UEnv.tydefs =
             (uu___157_1356.FStar_Extraction_ML_UEnv.tydefs);
           FStar_Extraction_ML_UEnv.currentModule = name
         } in
       let uu____1357 =
         FStar_Util.fold_map extract_sig g m.FStar_Syntax_Syntax.declarations in
       match uu____1357 with
       | (g,sigs) ->
           let mlm = FStar_List.flatten sigs in
           let is_kremlin =
             let uu____1374 = FStar_Options.codegen () in
             match uu____1374 with
             | Some "Kremlin" -> true
             | uu____1376 -> false in
           let uu____1378 =
             (((m.FStar_Syntax_Syntax.name).FStar_Ident.str <> "Prims") &&
                (is_kremlin ||
                   (Prims.op_Negation m.FStar_Syntax_Syntax.is_interface)))
               &&
               (FStar_Options.should_extract
                  (m.FStar_Syntax_Syntax.name).FStar_Ident.str) in
           if uu____1378
           then
             ((let _0_681 =
                 FStar_Syntax_Print.lid_to_string m.FStar_Syntax_Syntax.name in
               FStar_Util.print1 "Extracted module %s\n" _0_681);
              (g,
                [FStar_Extraction_ML_Syntax.MLLib
                   [(name, (Some ([], mlm)),
                      (FStar_Extraction_ML_Syntax.MLLib []))]]))
           else (g, []))