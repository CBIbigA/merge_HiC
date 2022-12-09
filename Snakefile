configfile: "config/config.yaml"

OUTDIR=config["general"]["sampleout"]

if config["general"]["rm_duplicates"]:
	outpair="dedup"
else:
	outpair="filtered"


# declare https://github.com/CBIbigA/HiC_pipeline as a module
module HiC_pipeline:
	snakefile: 
		github("CBIbigA/HiC_pipeline", path="workflow/Snakefile", branch="main")
	config:
		config



fused_files = {
	"fused_ABDF_DIVA":["H2VYVBGXJ_HiC_D_DIvA_21s001142-1-1_Clouaire_lane121s001142","H5KTGBGXC_HiC-manipB_DIvA_19s003262-1-1_Clouaire_lane119s003262","HTGLNBGXB_HiC-manipA_DIvA_19s003260-1-1_Clouaire_lane119s003260","AAANFH7HV_HIC_siCTRL94_DIVA_22s003294-1-1_Clouaire_lane1HICsiCTRL94DIVA"],
	"fused_ABDF_OHT":["H2WW7BGXJ_HiC_D_OHT_21s001143-1-1_Clouaire_lane121s001143","H75VVBGXC_HiC-manipB_OHT_19s003263-1-1_Clouaire_lane119s003263","HTGTMBGXB_HiC-manipA_OHT_19s003261-1-1_Clouaire_lane119s003261","AAANCTTHV_HIC_siCTRL94_OHT_22s003296-1-1_Clouaire_lane1HICsiCTRL94OHT"]
}


rule all:
	input: 
		expand(OUTDIR+"mapping/matrix/{prefix}."+outpair+".{type}",prefix=["fused_ABDF_DIVA","fused_ABDF_OHT"],type=["mcool","hic"])
	default_target: True


def GetPairFile(wildcards):
	print(wildcards.prefix)
	try:
		ccfiles = [OUTDIR+"mapping/pairtools/{0}.{1}.pairs".format(onepair,outpair) for onepair in fused_files[wildcards.prefix]]
	except KeyError:
		ccfiles=["error"]
	return(ccfiles)


rule merge_pair:
	input: GetPairFile
	output: OUTDIR+"mapping/pairtools/{prefix}."+outpair+".pairs"
	threads:config["general"]["threads"]["pairtools"]
	params:threads=config["general"]["threads"]["pairtools"]
	conda: "envs/pipeline.yaml"
	benchmark:
		OUTDIR+"benchmark/{prefix}/pairtools_merge.txt"
	shell:
		"pairtools merge --nproc {params.threads} -o {output} --tmpdir {resources.tmpdir} {input}"

use rule juicer_hic,bgzip,pairix,cooler,mcooler from HiC_pipeline as HiC_pipeline_*
