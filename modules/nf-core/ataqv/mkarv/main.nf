process ATAQV_MKARV {
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ataqv:1.3.1--py310ha155cf9_1':
        'biocontainers/ataqv:1.3.1--py310ha155cf9_1' }"

    input:
    path "jsons/*"

    output:
    path "html"        , emit: html
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkarv \\
        ${args} \\
        --concurrency ${task.cpus} \\
        --force \\
        ./html/ \\
        jsons/*

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        # mkarv: \$( mkarv --version ) # Use this when version string has been fixed
        ataqv: \$( ataqv --version )
    END_VERSIONS
    """

    stub:
    """
    mkdir -p html
    touch html/index.html
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        # mkarv: \$( mkarv --version ) # Use this when version string has been fixed
        ataqv: \$( ataqv --version )
    END_VERSIONS
    """
}
