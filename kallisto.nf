
params.results_dir = "results/"
params.INDEX = "/content/transcriptome/transcriptome.idx"
SRA_list = params.SRA.split(",")

log.info ""
log.info "  Q U A L I T Y   C O N T R O L  "
log.info "================================="
log.info "SRA number         : ${SRA_list}"
log.info "Index file         : ${params.INDEX}"
log.info "Results location   : ${params.results_dir}"

process DownloadFastQ {
  publishDir "${params.results_dir}"

  input:
    val sra

  output:
    path "${sra}/*"

  script:
    """
       /content/sratoolkit.3.0.0-ubuntu64/bin/fastq-dump ${sra} -X 10000 --split-3 -O ${sra}/
    """
}

  process Callisto {
    publishDir "${params.results_dir}"
    input:
      path x

    output:
      path "alignment/*"

    script:
    """
      mkdir alignment
      /content/kallisto/build/src/kallisto quant -i ${params.INDEX} -o alignment $x
    """
  }

workflow {
  data = Channel.of( SRA_list)
  DownloadFastQ(data)
  Callisto(DownloadFastQ.out)
}