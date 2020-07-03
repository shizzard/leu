-module(leu).
-include("leu_codegen.hrl").

-export([main/1]).



-spec main(Args :: [term()]) ->
	Ret :: ok.

main(Args) ->
	{ok, {ParsedArgs, PlainArgs}} = getopt:parse(getopts_spec(), Args),
	run_codegen(ParsedArgs, PlainArgs).



help() ->
	getopt:usage(getopts_spec(), erlang:atom_to_list(?MODULE)).



run_codegen(Args, _PlainArgs) ->
	case proplists:get_value(?leu_codegen_opts_source_file_name, Args) of
		undefined ->
			help();
		File ->
			handle_codegen_results(leu_codegen:generate(erlang:list_to_binary(File), maps:from_list(Args)))
	end.



handle_codegen_results(ok) ->
	io:format("Done~n"),
	halt(0);

handle_codegen_results(Error) ->
	handle_codegen_results_error(Error),
	halt(1).



handle_codegen_results_error({error, {load_schema, Reason}}) ->
	io:format("Error: unable to load schema file: ~p~n", [Reason]);
handle_codegen_results_error({error, {json, {badarg, _Stacktrace}}}) ->
	io:format("Error: unable to load schema file: invalid json", []);
handle_codegen_results_error({error, Error}) ->
	io:format("UNHANDLED: ~p~n", [Error]).



getopts_spec() ->
	[
		{?leu_codegen_opts_source_file_name, $i, "in", string, "JSON-Schema file (required)"},
		{?leu_codegen_opts_module_name, $m, "module", atom, "Module name for generated file, e.g. 'my_schema'"},
		{?leu_codegen_opts_output_dir, $o, "output_dir", string, "Output directory for generated module"}
	].
