name=${1}; as -c ${name}.S -o ${name}.o && gcc -g ${name}.o -o ${name} && ./${name}
