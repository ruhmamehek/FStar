
open Prims

let module_or_interface_name : FStar_Syntax_Syntax.modul  ->  (Prims.bool * FStar_Ident.lident) = (fun m -> (m.FStar_Syntax_Syntax.is_interface, m.FStar_Syntax_Syntax.name))


let parse : FStar_Parser_Env.env  ->  Prims.string Prims.option  ->  Prims.string  ->  (FStar_Parser_Env.env * FStar_Syntax_Syntax.modul Prims.list) = (fun env pre_fn fn -> (

let ast = (FStar_Parser_Driver.parse_file fn)
in (

let ast = (match (pre_fn) with
| None -> begin
ast
end
| Some (pre_fn) -> begin
(

let pre_ast = (FStar_Parser_Driver.parse_file pre_fn)
in (match ((pre_ast, ast)) with
| (FStar_Parser_AST.Interface (lid1, decls1, _87_13)::[], FStar_Parser_AST.Module (lid2, decls2)::[]) when (FStar_Ident.lid_equals lid1 lid2) -> begin
(let _176_11 = (let _176_10 = (let _176_9 = (FStar_Parser_Interleave.interleave decls1 decls2)
in (lid1, _176_9))
in FStar_Parser_AST.Module (_176_10))
in (_176_11)::[])
end
| _87_24 -> begin
(Prims.raise (FStar_Syntax_Syntax.Err ("mismatch between pre-module and module\n")))
end))
end)
in (FStar_Parser_ToSyntax.desugar_file env ast))))


let tc_prims : Prims.unit  ->  (FStar_Syntax_Syntax.modul * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun _87_26 -> (match (()) with
| () -> begin
(

let solver = if (FStar_Options.lax ()) then begin
FStar_SMTEncoding_Encode.dummy
end else begin
FStar_SMTEncoding_Encode.solver
end
in (

let env = (FStar_TypeChecker_Env.initial_env FStar_TypeChecker_Tc.type_of solver FStar_Syntax_Const.prims_lid)
in (

let _87_29 = (env.FStar_TypeChecker_Env.solver.FStar_TypeChecker_Env.init env)
in (

let p = (FStar_Options.prims ())
in (

let _87_34 = (let _176_14 = (FStar_Parser_Env.empty_env ())
in (parse _176_14 None p))
in (match (_87_34) with
| (dsenv, prims_mod) -> begin
(FStar_SMTEncoding_Z3.with_fuel_trace_cache p (fun _87_35 -> (match (()) with
| () -> begin
(

let _87_38 = (let _176_16 = (FStar_List.hd prims_mod)
in (FStar_TypeChecker_Tc.check_module env _176_16))
in (match (_87_38) with
| (prims_mod, env) -> begin
(prims_mod, dsenv, env)
end))
end)))
end))))))
end))


let tc_one_fragment : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_Parser_Env.env  ->  FStar_TypeChecker_Env.env  ->  Prims.string  ->  (FStar_Syntax_Syntax.modul Prims.option * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) Prims.option = (fun curmod dsenv env frag -> try
(match (()) with
| () -> begin
(match ((FStar_Parser_Driver.parse_fragment frag)) with
| FStar_Parser_Driver.Empty -> begin
Some ((curmod, dsenv, env))
end
| FStar_Parser_Driver.Modul (ast_modul) -> begin
(

let _87_64 = (FStar_Parser_ToSyntax.desugar_partial_modul curmod dsenv ast_modul)
in (match (_87_64) with
| (dsenv, modul) -> begin
(

let env = (match (curmod) with
| None -> begin
env
end
| Some (_87_67) -> begin
(Prims.raise (FStar_Syntax_Syntax.Err ("Interactive mode only supports a single module at the top-level")))
end)
in (

let _87_74 = (FStar_TypeChecker_Tc.tc_partial_modul env modul)
in (match (_87_74) with
| (modul, _87_72, env) -> begin
Some ((Some (modul), dsenv, env))
end)))
end))
end
| FStar_Parser_Driver.Decls (ast_decls) -> begin
(

let _87_79 = (FStar_Parser_ToSyntax.desugar_decls dsenv ast_decls)
in (match (_87_79) with
| (dsenv, decls) -> begin
(match (curmod) with
| None -> begin
(

let _87_81 = (FStar_Util.print_error "fragment without an enclosing module")
in (FStar_All.exit 1))
end
| Some (modul) -> begin
(

let _87_89 = (FStar_TypeChecker_Tc.tc_more_partial_modul env modul decls)
in (match (_87_89) with
| (modul, _87_87, env) -> begin
Some ((Some (modul), dsenv, env))
end))
end)
end))
end)
end)
with
| FStar_Syntax_Syntax.Error (msg, r) when (not ((FStar_Options.trace_error ()))) -> begin
(

let _87_50 = (FStar_TypeChecker_Errors.add_errors env (((msg, r))::[]))
in None)
end
| FStar_Syntax_Syntax.Err (msg) when (not ((FStar_Options.trace_error ()))) -> begin
(

let _87_54 = (FStar_TypeChecker_Errors.add_errors env (((msg, FStar_Range.dummyRange))::[]))
in None)
end
| e when (not ((FStar_Options.trace_error ()))) -> begin
(Prims.raise e)
end)


let pop_context : (FStar_Parser_Env.env * FStar_TypeChecker_Env.env)  ->  Prims.string  ->  Prims.unit = (fun _87_92 msg -> (match (_87_92) with
| (dsenv, env) -> begin
(

let _87_94 = (let _176_31 = (FStar_Parser_Env.pop dsenv)
in (FStar_All.pipe_right _176_31 Prims.ignore))
in (

let _87_96 = (let _176_32 = (FStar_TypeChecker_Env.pop env msg)
in (FStar_All.pipe_right _176_32 Prims.ignore))
in (env.FStar_TypeChecker_Env.solver.FStar_TypeChecker_Env.refresh ())))
end))


let push_context : (FStar_Parser_Env.env * FStar_TypeChecker_Env.env)  ->  Prims.string  ->  (FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun _87_100 msg -> (match (_87_100) with
| (dsenv, env) -> begin
(

let dsenv = (FStar_Parser_Env.push dsenv)
in (

let env = (FStar_TypeChecker_Env.push env msg)
in (dsenv, env)))
end))


let interactive_tc : ((FStar_Parser_Env.env * FStar_TypeChecker_Env.env), FStar_Syntax_Syntax.modul Prims.option) FStar_Interactive.interactive_tc = (

let pop = (fun _87_107 msg -> (match (_87_107) with
| (dsenv, env) -> begin
(

let _87_109 = (pop_context (dsenv, env) msg)
in (FStar_Options.pop ()))
end))
in (

let push = (fun _87_114 msg -> (match (_87_114) with
| (dsenv, env) -> begin
(

let res = (push_context (dsenv, env) msg)
in (

let _87_117 = (FStar_Options.push ())
in res))
end))
in (

let mark = (fun _87_122 -> (match (_87_122) with
| (dsenv, env) -> begin
(

let dsenv = (FStar_Parser_Env.mark dsenv)
in (

let env = (FStar_TypeChecker_Env.mark env)
in (

let _87_125 = (FStar_Options.push ())
in (dsenv, env))))
end))
in (

let reset_mark = (fun _87_130 -> (match (_87_130) with
| (dsenv, env) -> begin
(

let dsenv = (FStar_Parser_Env.reset_mark dsenv)
in (

let env = (FStar_TypeChecker_Env.reset_mark env)
in (

let _87_133 = (FStar_Options.pop ())
in (dsenv, env))))
end))
in (

let commit_mark = (fun _87_138 -> (match (_87_138) with
| (dsenv, env) -> begin
(

let dsenv = (FStar_Parser_Env.commit_mark dsenv)
in (

let env = (FStar_TypeChecker_Env.commit_mark env)
in (dsenv, env)))
end))
in (

let check_frag = (fun _87_144 curmod text -> (match (_87_144) with
| (dsenv, env) -> begin
try
(match (()) with
| () -> begin
(match ((tc_one_fragment curmod dsenv env text)) with
| Some (m, dsenv, env) -> begin
(let _176_59 = (let _176_58 = (FStar_TypeChecker_Errors.get_err_count ())
in (m, (dsenv, env), _176_58))
in Some (_176_59))
end
| _87_168 -> begin
None
end)
end)
with
| FStar_Syntax_Syntax.Error (msg, r) when (not ((FStar_Options.trace_error ()))) -> begin
(

let _87_154 = (FStar_TypeChecker_Errors.add_errors env (((msg, r))::[]))
in None)
end
| FStar_Syntax_Syntax.Err (msg) when (not ((FStar_Options.trace_error ()))) -> begin
(

let _87_158 = (let _176_63 = (let _176_62 = (let _176_61 = (FStar_TypeChecker_Env.get_range env)
in (msg, _176_61))
in (_176_62)::[])
in (FStar_TypeChecker_Errors.add_errors env _176_63))
in None)
end
end))
in (

let report_fail = (fun _87_170 -> (match (()) with
| () -> begin
(

let _87_171 = (let _176_66 = (FStar_TypeChecker_Errors.report_all ())
in (FStar_All.pipe_right _176_66 Prims.ignore))
in (FStar_ST.op_Colon_Equals FStar_TypeChecker_Errors.num_errs 0))
end))
in {FStar_Interactive.pop = pop; FStar_Interactive.push = push; FStar_Interactive.mark = mark; FStar_Interactive.reset_mark = reset_mark; FStar_Interactive.commit_mark = commit_mark; FStar_Interactive.check_frag = check_frag; FStar_Interactive.report_fail = report_fail})))))))


let tc_one_file : FStar_Parser_Env.env  ->  FStar_TypeChecker_Env.env  ->  Prims.string Prims.option  ->  Prims.string  ->  (FStar_Syntax_Syntax.modul Prims.list * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun dsenv env pre_fn fn -> (

let _87_179 = (parse dsenv pre_fn fn)
in (match (_87_179) with
| (dsenv, fmods) -> begin
(FStar_SMTEncoding_Z3.with_fuel_trace_cache fn (fun _87_180 -> (match (()) with
| () -> begin
(

let _87_190 = (FStar_All.pipe_right fmods (FStar_List.fold_left (fun _87_183 m -> (match (_87_183) with
| (env, all_mods) -> begin
(

let _87_187 = (FStar_TypeChecker_Tc.check_module env m)
in (match (_87_187) with
| (m, env) -> begin
(env, (m)::all_mods)
end))
end)) (env, [])))
in (match (_87_190) with
| (env, all_mods) -> begin
((FStar_List.rev all_mods), dsenv, env)
end))
end)))
end)))


let needs_interleaving : Prims.string  ->  Prims.string  ->  Prims.bool = (fun intf impl -> (

let m1 = (FStar_Parser_Dep.lowercase_module_name intf)
in (

let m2 = (FStar_Parser_Dep.lowercase_module_name impl)
in (((m1 = m2) && ((FStar_Util.get_file_extension intf) = "fsti")) && ((FStar_Util.get_file_extension impl) = "fst")))))


let rec tc_fold_interleave : (FStar_Syntax_Syntax.modul Prims.list * FStar_Parser_Env.env * FStar_TypeChecker_Env.env)  ->  Prims.string Prims.list  ->  (FStar_Syntax_Syntax.modul Prims.list * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun acc remaining -> (

let move = (fun intf impl remaining -> (

let _87_201 = (FStar_Syntax_Syntax.reset_gensym ())
in (

let _87_206 = acc
in (match (_87_206) with
| (all_mods, dsenv, env) -> begin
(

let _87_231 = (match (intf) with
| None -> begin
(tc_one_file dsenv env intf impl)
end
| Some (_87_209) when ((FStar_Options.codegen ()) <> None) -> begin
(

let _87_211 = if (not ((FStar_Options.lax ()))) then begin
(Prims.raise (FStar_Syntax_Syntax.Err ("Verification and code generation are no supported together with partial modules (i.e, *.fsti); use --lax to extract code separately")))
end else begin
()
end
in (tc_one_file dsenv env intf impl))
end
| Some (iname) -> begin
(

let _87_215 = (FStar_Util.print1 "Interleaving iface+module: %s\n" iname)
in (

let caption = (Prims.strcat "interface: " iname)
in (

let _87_220 = (push_context (dsenv, env) caption)
in (match (_87_220) with
| (dsenv', env') -> begin
(

let _87_225 = (tc_one_file dsenv' env' intf impl)
in (match (_87_225) with
| (_87_222, dsenv', env') -> begin
(

let _87_226 = (pop_context (dsenv', env') caption)
in (tc_one_file dsenv env None iname))
end))
end))))
end)
in (match (_87_231) with
| (ms, dsenv, env) -> begin
(

let acc = ((FStar_List.append all_mods ms), dsenv, env)
in (tc_fold_interleave acc remaining))
end))
end))))
in (match (remaining) with
| intf::impl::remaining when (needs_interleaving intf impl) -> begin
(move (Some (intf)) impl remaining)
end
| intf_or_impl::remaining -> begin
(move None intf_or_impl remaining)
end
| [] -> begin
acc
end)))


let batch_mode_tc_no_prims : FStar_Parser_Env.env  ->  FStar_TypeChecker_Env.env  ->  Prims.string Prims.list  ->  (FStar_Syntax_Syntax.modul Prims.list * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun dsenv env filenames -> (

let _87_248 = (tc_fold_interleave ([], dsenv, env) filenames)
in (match (_87_248) with
| (all_mods, dsenv, env) -> begin
(

let _87_249 = if ((FStar_Options.interactive ()) && ((FStar_TypeChecker_Errors.get_err_count ()) = 0)) then begin
(env.FStar_TypeChecker_Env.solver.FStar_TypeChecker_Env.refresh ())
end else begin
(env.FStar_TypeChecker_Env.solver.FStar_TypeChecker_Env.finish ())
end
in (all_mods, dsenv, env))
end)))


let batch_mode_tc : Prims.string Prims.list  ->  (FStar_Syntax_Syntax.modul Prims.list * FStar_Parser_Env.env * FStar_TypeChecker_Env.env) = (fun filenames -> (

let _87_255 = (tc_prims ())
in (match (_87_255) with
| (prims_mod, dsenv, env) -> begin
(

let filenames = (FStar_Dependences.find_deps_if_needed filenames)
in (

let _87_261 = if ((not ((FStar_Options.explicit_deps ()))) && (FStar_Options.debug_any ())) then begin
(

let _87_257 = (FStar_Util.print_endline "Auto-deps kicked in; here\'s some info.")
in (

let _87_259 = (FStar_Util.print1 "Here\'s the list of filenames we will process: %s\n" (FStar_String.concat " " filenames))
in (let _176_101 = (let _176_100 = (FStar_Options.verify_module ())
in (FStar_String.concat " " _176_100))
in (FStar_Util.print1 "Here\'s the list of modules we will verify: %s\n" _176_101))))
end else begin
()
end
in (

let _87_266 = (batch_mode_tc_no_prims dsenv env filenames)
in (match (_87_266) with
| (all_mods, dsenv, env) -> begin
((prims_mod)::all_mods, dsenv, env)
end))))
end)))




