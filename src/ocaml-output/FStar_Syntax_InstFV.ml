
open Prims
open FStar_Pervasives

type inst_t =
(FStar_Ident.lident * FStar_Syntax_Syntax.universes) Prims.list


let mk : 'Auu____14 'Auu____15 . 'Auu____14 FStar_Syntax_Syntax.syntax  ->  'Auu____15  ->  'Auu____15 FStar_Syntax_Syntax.syntax = (fun t s -> (FStar_Syntax_Syntax.mk s FStar_Pervasives_Native.None t.FStar_Syntax_Syntax.pos))


let rec inst : (FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun s t -> (

let t1 = (FStar_Syntax_Subst.compress t)
in (

let mk1 = (mk t1)
in (match (t1.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_delayed (uu____145) -> begin
(failwith "Impossible")
end
| FStar_Syntax_Syntax.Tm_name (uu____169) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_uvar (uu____170) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_uvar (uu____183) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_type (uu____196) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_bvar (uu____197) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_constant (uu____198) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_quoted (uu____199) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_unknown -> begin
t1
end
| FStar_Syntax_Syntax.Tm_uinst (uu____206) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_lazy (uu____213) -> begin
t1
end
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(s t1 fv)
end
| FStar_Syntax_Syntax.Tm_abs (bs, body, lopt) -> begin
(

let bs1 = (inst_binders s bs)
in (

let body1 = (inst s body)
in (

let uu____244 = (

let uu____245 = (

let uu____264 = (inst_lcomp_opt s lopt)
in ((bs1), (body1), (uu____264)))
in FStar_Syntax_Syntax.Tm_abs (uu____245))
in (mk1 uu____244))))
end
| FStar_Syntax_Syntax.Tm_arrow (bs, c) -> begin
(

let bs1 = (inst_binders s bs)
in (

let c1 = (inst_comp s c)
in (mk1 (FStar_Syntax_Syntax.Tm_arrow (((bs1), (c1)))))))
end
| FStar_Syntax_Syntax.Tm_refine (bv, t2) -> begin
(

let bv1 = (

let uu___47_322 = bv
in (

let uu____323 = (inst s bv.FStar_Syntax_Syntax.sort)
in {FStar_Syntax_Syntax.ppname = uu___47_322.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___47_322.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = uu____323}))
in (

let t3 = (inst s t2)
in (mk1 (FStar_Syntax_Syntax.Tm_refine (((bv1), (t3)))))))
end
| FStar_Syntax_Syntax.Tm_app (t2, args) -> begin
(

let uu____355 = (

let uu____356 = (

let uu____373 = (inst s t2)
in (

let uu____376 = (inst_args s args)
in ((uu____373), (uu____376))))
in FStar_Syntax_Syntax.Tm_app (uu____356))
in (mk1 uu____355))
end
| FStar_Syntax_Syntax.Tm_match (t2, pats) -> begin
(

let pats1 = (FStar_All.pipe_right pats (FStar_List.map (fun uu____508 -> (match (uu____508) with
| (p, wopt, t3) -> begin
(

let wopt1 = (match (wopt) with
| FStar_Pervasives_Native.None -> begin
FStar_Pervasives_Native.None
end
| FStar_Pervasives_Native.Some (w) -> begin
(

let uu____546 = (inst s w)
in FStar_Pervasives_Native.Some (uu____546))
end)
in (

let t4 = (inst s t3)
in ((p), (wopt1), (t4))))
end))))
in (

let uu____552 = (

let uu____553 = (

let uu____576 = (inst s t2)
in ((uu____576), (pats1)))
in FStar_Syntax_Syntax.Tm_match (uu____553))
in (mk1 uu____552)))
end
| FStar_Syntax_Syntax.Tm_ascribed (t11, asc, f) -> begin
(

let inst_asc = (fun uu____669 -> (match (uu____669) with
| (annot, topt) -> begin
(

let topt1 = (FStar_Util.map_opt topt (inst s))
in (

let annot1 = (match (annot) with
| FStar_Util.Inl (t2) -> begin
(

let uu____731 = (inst s t2)
in FStar_Util.Inl (uu____731))
end
| FStar_Util.Inr (c) -> begin
(

let uu____739 = (inst_comp s c)
in FStar_Util.Inr (uu____739))
end)
in ((annot1), (topt1))))
end))
in (

let uu____752 = (

let uu____753 = (

let uu____780 = (inst s t11)
in (

let uu____783 = (inst_asc asc)
in ((uu____780), (uu____783), (f))))
in FStar_Syntax_Syntax.Tm_ascribed (uu____753))
in (mk1 uu____752)))
end
| FStar_Syntax_Syntax.Tm_let (lbs, t2) -> begin
(

let lbs1 = (

let uu____848 = (FStar_All.pipe_right (FStar_Pervasives_Native.snd lbs) (FStar_List.map (fun lb -> (

let uu___89_863 = lb
in (

let uu____864 = (inst s lb.FStar_Syntax_Syntax.lbtyp)
in (

let uu____867 = (inst s lb.FStar_Syntax_Syntax.lbdef)
in {FStar_Syntax_Syntax.lbname = uu___89_863.FStar_Syntax_Syntax.lbname; FStar_Syntax_Syntax.lbunivs = uu___89_863.FStar_Syntax_Syntax.lbunivs; FStar_Syntax_Syntax.lbtyp = uu____864; FStar_Syntax_Syntax.lbeff = uu___89_863.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = uu____867; FStar_Syntax_Syntax.lbattrs = uu___89_863.FStar_Syntax_Syntax.lbattrs; FStar_Syntax_Syntax.lbpos = uu___89_863.FStar_Syntax_Syntax.lbpos}))))))
in (((FStar_Pervasives_Native.fst lbs)), (uu____848)))
in (

let uu____876 = (

let uu____877 = (

let uu____891 = (inst s t2)
in ((lbs1), (uu____891)))
in FStar_Syntax_Syntax.Tm_let (uu____877))
in (mk1 uu____876)))
end
| FStar_Syntax_Syntax.Tm_meta (t2, FStar_Syntax_Syntax.Meta_pattern (bvs, args)) -> begin
(

let uu____942 = (

let uu____943 = (

let uu____950 = (inst s t2)
in (

let uu____953 = (

let uu____954 = (

let uu____975 = (FStar_All.pipe_right args (FStar_List.map (inst_args s)))
in ((bvs), (uu____975)))
in FStar_Syntax_Syntax.Meta_pattern (uu____954))
in ((uu____950), (uu____953))))
in FStar_Syntax_Syntax.Tm_meta (uu____943))
in (mk1 uu____942))
end
| FStar_Syntax_Syntax.Tm_meta (t2, FStar_Syntax_Syntax.Meta_monadic (m, t')) -> begin
(

let uu____1061 = (

let uu____1062 = (

let uu____1069 = (inst s t2)
in (

let uu____1072 = (

let uu____1073 = (

let uu____1080 = (inst s t')
in ((m), (uu____1080)))
in FStar_Syntax_Syntax.Meta_monadic (uu____1073))
in ((uu____1069), (uu____1072))))
in FStar_Syntax_Syntax.Tm_meta (uu____1062))
in (mk1 uu____1061))
end
| FStar_Syntax_Syntax.Tm_meta (t2, tag) -> begin
(

let uu____1093 = (

let uu____1094 = (

let uu____1101 = (inst s t2)
in ((uu____1101), (tag)))
in FStar_Syntax_Syntax.Tm_meta (uu____1094))
in (mk1 uu____1093))
end))))
and inst_binders : (FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.binders  ->  FStar_Syntax_Syntax.binders = (fun s bs -> (FStar_All.pipe_right bs (FStar_List.map (fun uu____1136 -> (match (uu____1136) with
| (x, imp) -> begin
(

let uu____1155 = (

let uu___115_1156 = x
in (

let uu____1157 = (inst s x.FStar_Syntax_Syntax.sort)
in {FStar_Syntax_Syntax.ppname = uu___115_1156.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___115_1156.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = uu____1157}))
in ((uu____1155), (imp)))
end)))))
and inst_args : (FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option) Prims.list  ->  (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option) Prims.list = (fun s args -> (FStar_All.pipe_right args (FStar_List.map (fun uu____1212 -> (match (uu____1212) with
| (a, imp) -> begin
(

let uu____1231 = (inst s a)
in ((uu____1231), (imp)))
end)))))
and inst_comp : (FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax  ->  FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax = (fun s c -> (match (c.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Total (t, uopt) -> begin
(

let uu____1254 = (inst s t)
in (FStar_Syntax_Syntax.mk_Total' uu____1254 uopt))
end
| FStar_Syntax_Syntax.GTotal (t, uopt) -> begin
(

let uu____1265 = (inst s t)
in (FStar_Syntax_Syntax.mk_GTotal' uu____1265 uopt))
end
| FStar_Syntax_Syntax.Comp (ct) -> begin
(

let ct1 = (

let uu___134_1268 = ct
in (

let uu____1269 = (inst s ct.FStar_Syntax_Syntax.result_typ)
in (

let uu____1272 = (inst_args s ct.FStar_Syntax_Syntax.effect_args)
in (

let uu____1283 = (FStar_All.pipe_right ct.FStar_Syntax_Syntax.flags (FStar_List.map (fun uu___0_1293 -> (match (uu___0_1293) with
| FStar_Syntax_Syntax.DECREASES (t) -> begin
(

let uu____1297 = (inst s t)
in FStar_Syntax_Syntax.DECREASES (uu____1297))
end
| f -> begin
f
end))))
in {FStar_Syntax_Syntax.comp_univs = uu___134_1268.FStar_Syntax_Syntax.comp_univs; FStar_Syntax_Syntax.effect_name = uu___134_1268.FStar_Syntax_Syntax.effect_name; FStar_Syntax_Syntax.result_typ = uu____1269; FStar_Syntax_Syntax.effect_args = uu____1272; FStar_Syntax_Syntax.flags = uu____1283}))))
in (FStar_Syntax_Syntax.mk_Comp ct1))
end))
and inst_lcomp_opt : (FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.fv  ->  FStar_Syntax_Syntax.term)  ->  FStar_Syntax_Syntax.residual_comp FStar_Pervasives_Native.option  ->  FStar_Syntax_Syntax.residual_comp FStar_Pervasives_Native.option = (fun s l -> (match (l) with
| FStar_Pervasives_Native.None -> begin
FStar_Pervasives_Native.None
end
| FStar_Pervasives_Native.Some (rc) -> begin
(

let uu____1312 = (

let uu___146_1313 = rc
in (

let uu____1314 = (FStar_Util.map_opt rc.FStar_Syntax_Syntax.residual_typ (inst s))
in {FStar_Syntax_Syntax.residual_effect = uu___146_1313.FStar_Syntax_Syntax.residual_effect; FStar_Syntax_Syntax.residual_typ = uu____1314; FStar_Syntax_Syntax.residual_flags = uu___146_1313.FStar_Syntax_Syntax.residual_flags}))
in FStar_Pervasives_Native.Some (uu____1312))
end))


let instantiate : inst_t  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun i t -> (match (i) with
| [] -> begin
t
end
| uu____1338 -> begin
(

let inst_fv = (fun t1 fv -> (

let uu____1350 = (FStar_Util.find_opt (fun uu____1364 -> (match (uu____1364) with
| (x, uu____1371) -> begin
(FStar_Ident.lid_equals x fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end)) i)
in (match (uu____1350) with
| FStar_Pervasives_Native.None -> begin
t1
end
| FStar_Pervasives_Native.Some (uu____1376, us) -> begin
(mk t1 (FStar_Syntax_Syntax.Tm_uinst (((t1), (us)))))
end)))
in (inst inst_fv t))
end))




