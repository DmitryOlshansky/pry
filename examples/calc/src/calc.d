module calc;

import pry;

import std.stdio, std.conv;

alias S = SimpleStream!string;

auto makeParser(){
	with(parsers!S) {
		auto expr = dynamic!int;
		auto primary = any(
			range!('0', '9').rep.map!(x => x.to!int),
			seq(tk!'(', expr, tk!')').map!(x => x[1])
		);
		auto term = dynamic!int;
		term = any(
			seq(primary, tk!'*', term).map!(x => x[0] * x[2]),
			seq(primary, tk!'/', term).map!(x => x[0] / x[2]),
			primary
		);
		expr = any(
			seq(term, tk!'+', expr).map!(x => x[0] + x[2]),
			seq(term, tk!'-', expr).map!(x => x[0] - x[2]),
			term
		);
		return expr;
	}
}

void main(){
	auto parser = makeParser();
	for(;;){
		string s = readln();
		int value;
		S.Error err;
		if(s == null) break;
		auto stream = S(s[0..$-1]); // chomp '\n'
		bool success = parser.parse(stream, value, err);
		if(success && stream.empty){
			writeln("=", value);
		}
		else if(success && !stream.empty){
			writeln("Failed to parse, the leftover is : ", s[stream.location..$-1]);
		} else {
			writeln("Error at ", err.location, " ", err.reason);
		}
	}
}
