#!/bin/gawk

# For arguments (subjects and objects) of semantic relation instances, find:
#	arg_name:		Name of the argument, CUI is key, "name" is the value
# 	arg_min_pyear: Find year of first occurrence (minimum year)
#	arg_inst_freq: Total instance frequency - in how many instances it occurs?
#	arg_rel_freq:  Total relation frequency - in how many distinct relations it occurs?
#	#arg_pyear:     History of occurrence (year1:freq1, year2:freq2, ..., yearN:freqN)
#!!! Neo4j supports arrays of simple types as properties, but not arrays of pairs (year, freq).
#!!! Therefore the above arg_pyear becomes two fields (arrays of same length), one for the years, another for frequences
#	arg_pyear:		Array of published years, e.g. [1991,1992, ...,2000]
#	arg_pfreq:		Array of freqcuences for corresponding years, e.g. [1,2, ...,10]
#	Do we need separate History for instances and for relations?
# 	If yes, in which format, separate fields, or one field (year1:[inst_freq1,rel_fref1], year2:[inst_freq2,rel_freq2], yearN:[inst_freqN,rel_freqN])
#	arg_stys:      Semantic type(s) as a list: sty1;sty2;sty3;...;styN
#	arg_stys_freq: Semantic types frequences (sty1:freq1, sty2:freq2, styN:freqN)
#	Argument as a subject only:
#		sub_inst_freq:	Total instance frequency
#		sub_rel_feq:	Total relation frequency/count. In how many different aggregated relations occurrs?
#		sub_min_pyear:	The year in which the argument occurred as a subject for the first time
#		sub_pyear:		History of occurrence (like above). Array of pub years SEE ABOVE!!!
#		sub_pfreq:		Arrays of pub frequences for year in sub_pyear
#	Argument as an object only:
#		obj_inst_freq:	Total instance frequency
#		obj_rel_freq:	Total relation frequency
#		obj_min_pyear
#		obj_pyear:		History of occurrence (like above). Array of pub years
#		obj_pfreq:		Array of pub frequences for years in obj_pyear array
#
# For semantic relation instances:	 
# 	Aggregates semantic relation instances into semantic relations and counts:
#		rel_freq:	Semantic relation frequency
#		rel_min_pyear:	 - year of first occurrence of a relation
#!!! Someone wanted the next two fields. The challenge: there can be more than one pmid and sentence in the first year of occurrence
#!!! Quick and dirty would be: an array for the pmids and an array for the sentences or semtence_ids.
#!!! Maybe better option is to have relationships FIRST_CITATION and FIRST_SENTENCE. Actually we 
#!!! need only FIRST_SENTENCE because from the sentence we can go to the CITATION if needed.
#!!! But, we CAN NOT have relations from a relation to other nodes. We need HYPER-EDGES. 
#!!! Therefore, we use arrays or we make a semantic relation a hyper-adge (node)
#		rel_min_pmid:	Array of pmids where the first occurrences happened
#		rel_min_sentence: Array of sentence(s) (or sentence_ids) where the first occurrences happened
#		rel_pyear:	History of occurrence. Array of pub years.
#		rel_pfreq:	Array of frequences for years in rel_pyear.
#	Output format for aggregated semantic relations:
#		sub rel obj min_pyear rel_freq year1;year2;...;yearN freq1;freq2;...;freqN
#
# INPUT: sub_rel_obj_pyear_pmid_sent_id.txt
# USAGE: gawk -f semmed42_arg_rel_min_pyear.awk sub_rel_obj_pyear_pmid_sent_id.txt 
# OUTPUT: The output is written in four separate files:
#   semmed42_arg_stys_min_pyear_pfreq_hdr.txt - header file for the argument nodes
#   semmed42_arg_stys_min_pyear_pfreq.txt     - the argument/concept nodes
#   semmed42_rel_freq_min_pyear_pfreq_hdr.txt - header file for the aggregated semantic relations
#   semmed42_rel_freq_min_pyear_pfreq.txt     - the aggregated relations


BEGIN { FS="\t"; OFS="\t"} 
	{ 
	 

     # Argument names
     arg[$1]["name"] = $2;
     arg[$5]["name"] = $6;

     # for the subject, count how many times each sty occurs. 
     # In the end, for each argument, we have an array of semantic types and frequences as instances
	 arg[$1]["sty"][$3]++;  
	 # similar for the object, ...
	 arg[$5]["sty"][$7]++;

	 # arg_inst_freq: intance frequency of an argument
	 arg_inst_freq[$1]++; # $1 is the subject CUI
	 arg_inst_freq[$5]++; # $5 is the object CUI
	 sub_inst_freq[$1]++; # instance frequency as a subject only
	 obj_inst_freq[$5]++; # instance frequency as on object only
	 # The corresponding "aggregated relation" frequencies are calculated bellow after the aggregation 
	 #		from instances to relations

	 # Year of first occurrence for arguments
	 # argument as a subject
	 # $1 is the subject. $8 is the publication year. First as any argument
	 if ($1 in arg_min_pyear) {
	 	if ($8+0<arg_min_pyear[$1]+0) 
	 		{ arg_min_pyear[$1]=$8+0 };
	 } 
	 else {
	 	arg_min_pyear[$1]=$8+0
	 }
	 # as a subject
	 if ($1 in sub_min_pyear) {
	 	if ($8+0<sub_min_pyear[$1]+0) 
	 		{ sub_min_pyear[$1]=$8+0 };
	 } 
	 else {
	 	sub_min_pyear[$1]=$8+0
	 }


	 # $5 is the object. First as any argument 
	 if ($5 in arg_min_pyear) {
	 	if ($8+0<arg_min_pyear[$5]+0) 
	 		{ arg_min_pyear[$5]=$8+0 };
	 } 
	 else {
	 	arg_min_pyear[$5]=$8+0;
	 }
	 # as an object
	 if ($5 in obj_min_pyear) {
	 	if ($8+0<obj_min_pyear[$5]+0) 
	 		{ obj_min_pyear[$5]=$8+0 };
	 } 
	 else {
	 	obj_min_pyear[$5]=$8+0;
	 }
	 ####

	 # arg_pyear: history of occurrence for the argument
	 arg_pyear[$1][$8]++; # For argument $1 (subject) for pyear $8 increment the counter
	 arg_pyear[$5][$8]++; # For argument $5 (object) for pyear $8 increment the counter
	 ####

	 # sub_pyear: history of occurrence for the argument as a subject
	 # sub_pyear[$1][$8]++; # For argument $1 (subject) for pyear $8 increment the counter
	 ####

	 # obj_pyear: history of occurrence for the argument as an object
	 # obj_pyear[$5][$8]++; # For argument $5 (object) for pyear $8 increment the counter
	 ####

	 # From relation instances to aggregated relations.
	 # Using array of array (gawk extension - does not work in plain awk)
	 rel[$1][$5][$4]["freq"]++;

	 # History of a relation. For each, subject, object, predicate, year of publication, increment the counter
	 rel[$1][$5][$4]["pyear"][$8]++;

	 # Year of first occurrence of a relation: subject, object, predicate
	 if (($1, $5, $4, "min") in rel) {
	 	if ($8+0<rel[$1][$5][$4]["min"]+0) { 
	 		# New minimum year found
	 		rel[$1][$5][$4]["min"] = $8+0;
	 		# delete rel[$1][$5][$4]["pmid"]; # We delete only for new minimum year
	 		# rel[$1][$5][$4]["pmid"][$9] = $10; # $9 is the pmid, $10 is the sentence_id
	 	}
	 	else if ($8+0 == rel[$1][$5][$4]["min"]+0) {
	 		# Instance with same minimum year. Append the pmid and sentence_id
	 		# We comment the next line to do NOTHING, we just keep the first minimum pmid and sentence_id
	 		# If you want a list of pmid-s and sentence_id-s, un-comment the next line
	 		# rel[$1][$5][$4]["pmid"][$9] = $10;
	 	}
	 }
	 else {
	 	# The first time publication year is found. It becomes the first minimum pub year
	 	rel[$1][$5][$4]["min"] = $8 + 0;
	 	# rel[$1][$5][$4]["pmid"][$9] = $10;
	 }


	} 
END {
	 # PROCINFO["sorted_in"] = "@ind_str_asc"; # sort the arrays by key ascending in all "for (x in array_something)"
	 # Print the relations file
	 # Print the header file for the relations
	 print "sub_cui","obj_cui","relation","freq","min_pyear","pyear_list","pfreq_list" >"semmed42_rel_freq_min_pyear_pfreq_hdr.txt"; # "min_pmid_list","min_sent_id_list",

	 # Print the relations
	 for (subject in rel) {
	 	for (object in rel[subject]) {
	 		for (relation in rel[subject][object]) {
	 			# arg_rel_freq: argument aggregated relation frequency
	 			arg_rel_freq[subject]++;
	 			arg_rel_freq[object]++;
	 			sub_rel_freq[subject]++;
	 			obj_rel_freq[object]++;
	 			# prepare a list of yr1:freq1;yr2:freq2;...;yrN;freqN for each sub,obj,rel combination
	 			rel_pyear_list = "";
	 			rel_pfreq_list = "";
	 			for (yr in rel[subject][object][relation]["pyear"]) {
	 				rel_pyear_list = rel_pyear_list ";" yr;
	 				rel_pfreq_list = rel_pfreq_list ";" rel[subject][object][relation]["pyear"][yr];
	 			}
	 			rel_pyear_list = substr(rel_pyear_list,2);
	 			rel_pfreq_list = substr(rel_pfreq_list,2);
	 			# now the relation pub history is in rel_pyear_list and in rel_pfreq_list as a string

	 			# Prepare rel_min_pmid_list and rel_min_sent_id_list
	 			# rel_min_pmid_list = "";
	 			# rel_min_sent_id_list = "";
	 			# for (pmid in rel[subject][object][relation]["pmid"]) {
	 			# 	rel_min_pmid_list = rel_min_pmid_list ";" pmid;
	 			# 	rel_min_sent_id_list = rel_min_sent_id_list ";" rel[subject][object][relation]["pmid"][pmid];
	 			# }
	 			# rel_min_pmid_list = substr(rel_min_pmid_list,2);
	 			# rel_min_sent_id_list = substr(rel_min_sent_id_list,2);
	 			###

	 			print subject,object,relation, rel[subject][object][relation]["freq"], rel[subject][object][relation]["min"], rel_pyear_list, rel_pfreq_list >"semmed42_rel_freq_min_pyear_pfreq.txt"; # rel_min_pmid_list, rel_min_sent_id_list, 
	 		}
	 	}
	 }

	 # Print the arguments file
	 # Print the header file for the arguments
	 print "cui","name","sty_list","sty_freq_list","min_pyear","arg_pyear_list","arg_pfreq_list","arg_inst_freq","arg_rel_freq","sub_inst_freq","sub_rel_freq","obj_inst_freq","obj_rel_freq" >"semmed42_arg_stys_min_pyear_pfreq_hdr.txt"; 
	 # Print the arguments
	 for (c in arg_min_pyear) { # "c" is CUI
	 	# Prepare sty_list as a string
	 	sty_list = "";
	 	sty_freq_list = "";
	 	for (sty in arg[c]["sty"]) {
	 		# was: sty_list = sty_list ";" sty ":" arg_stys[c][sty];
	 		sty_list = sty_list ";" sty;
	 		sty_freq_list = sty_freq_list ";" arg[c]["sty"][sty];
	 	}
	 	sty_list = substr(sty_list,2); # skip the ";" as a first character
	 	sty_freq_list = substr(sty_freq_list,2);
	 	#
	 	# prepare a list of yr1;yr2;...;yrN and freq1;freq2;...;freqN for each argument
	 	arg_pyear_list = "";
	 	arg_pfreq_list = "";
	 	for (yr in arg_pyear[c]) {
	 		arg_pyear_list = arg_pyear_list ";" yr;
	 		arg_pfreq_list = arg_pfreq_list ";" arg_pyear[c][yr];
	 	}
	 	arg_pyear_list = substr(arg_pyear_list,2);
	 	arg_pfreq_list = substr(arg_pfreq_list,2);
	 	# Now the argument pub history years are in arg_pyear_list as a string
	 	# the frequencies are in arg_pfreq_list
	 	# Similar can be done if needed for: sub_pyear_list and obj_pyear_list

	 	print c, arg[c]["name"], sty_list, sty_freq_list, arg_min_pyear[c], arg_pyear_list, arg_pfreq_list, arg_inst_freq[c], arg_rel_freq[c], sub_inst_freq[c], sub_rel_freq[c], obj_inst_freq[c], obj_rel_freq[c] >"semmed42_arg_stys_min_pyear_pfreq.txt";
	 }

	}
