-module(leu_codegen).
-include("leu_codegen.hrl").

-export([generate/2]).



-spec generate(
	Filename :: unicode:chardata(),
	Opts :: maps:map()
) ->
	{ok, GeneratedModuleFilename :: unicode:chardata()} | {error, Reason :: term()}.

generate(Filename, Opts) ->
	try
		generate_module_name(Filename, Opts#{?leu_codegen_opts_source_file_name => Filename})
	catch
		_T:E -> {error, E}
	end.



generate_module_name(Filename, #{?leu_codegen_opts_module_name := ModuleName} = Opts)
when is_atom(ModuleName) ->
	generate_read_file(Filename, Opts);

generate_module_name(_Filename, #{?leu_codegen_opts_module_name := _ModuleName} = _Opts) ->
	throw({load_schema, invalid_module_name});

generate_module_name(Filename, Opts) ->
	ModuleName = filename:rootname(filename:basename(Filename)),
	generate_read_file(
		Filename,
		Opts#{?leu_codegen_opts_module_name => erlang:binary_to_atom(ModuleName, latin1)}
	).



generate_read_file(Filename, Opts) ->
	case file:read_file(Filename) of
		{ok, Binary} ->
			generate_decode_json(Binary, Opts#{});
		{error, Reason} ->
			throw({load_schema, Reason})
	end.



generate_decode_json(Binary, Opts) ->
	case jsone:try_decode(
		Binary, [{object_format, map}, reject_invalid_utf8, {keys, binary}]
	) of
		{ok, Schema, _Continuation} ->
			generate_code(Schema, Opts);
		{error, Reason} ->
			throw({json, Reason})
	end.



generate_code(_Schema, _Opts) ->
	ok.
