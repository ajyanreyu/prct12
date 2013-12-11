#
# = matrix_DSL.rb
#  
#    Autores::   Teno González Dos Santos,  Albano José Yanes Reyes
#    Fecha:: 27/11/2013 
#    Asignatura:: Lenguajes y Paradigmas de Programación
#    Curso:: Tercero de Grado en Ingeniería Informática
#    Universidad de la Laguna
#
#  == Practica 12:  Lenguaje de Dominio Específico
#          <b>Diseñar y desarrollar un <em>DSL</em> interno para trabajar con matrices.</b>
#          <b>Utilizar Gemnasium para comprobar las dependencias de la aplicación desarrollada.</b>
#
#  === Clase matriz_DSL
#        Definicion de la clase Matriz_DSL compuesta por:
#          - def operand (matriz)
#          - def option(opcion)
#          - def ejecucion
#

require "./lib/matrix_expansion/matrix.rb"

module MatrixExpansion
    class MatrizDSL < Matriz
        attr_accessor :result
        
        # Función que permite usar un DSL con lenguaje más sencillo para realizar operaciones matrices.
        # Se le pasan por parámetro el tipo de operacion y un bloque con el resto de opciones y operandos.
        def initialize(op_type, &block)
            raise ArgumentError , 'Tipo invalido' unless op_type.is_a? String
            
            @operands = []      # Aquí se almacenan los operandos, es decir, las matrices
            @result_mode = :correccion_auto     # modo para mostrar el resultado
            @result = nil   # Resultado de operación
            @mode = :console    # Modo de ejecución
            @operation = :mostrar   # tipo operación a realizar
            
            
            case op_type
                when "suma"
                    @operation = :suma
                when "resta"
                    @operation = :resta
                when "producto"
                    @operation = :producto
                when "mostrar"
                    @operation = :mostrar
                else
                    puts "Opcion incorrecta", op_type
            end
            
            if block_given?  
                if block.arity == 1
                    yield self
                else
                    instance_eval &block 
                end
            end
            
            ejecucion
        end
        
        # Método que recoge los operandos pasados (matrices)
        protected
        def operand (matriz)
            raise ArgumentError , 'Tipo invalido' unless matriz.is_a? Array
          
            @operands << Matriz_Densa.read(matriz)
        end
        
        # Método que asigna la opción seleccionada
        def option(opcion)
            raise ArgumentError , 'Tipo invalido' unless opcion.is_a? String
            opc = opcion.downcase
          
            case opc
                when "densa"
                    @result_mode = :densa
                when "dispersa"
                    @result_mode = :dispersa
                when "correccion_auto"
                    @result_mode = :correccion_auto     # Comprueba automáticamente si es necesaria la conversión a dispersa del resultado
                when "console"
                    @mode = :console    # Mostrar resultado por consola
                when "file"
                    @mode = :file   # Crear un fichero que contiene el resultado
                when "none"
                    @mode = :none   # Modo que no hace nada, sino devolver el resultado sin mostrarlo
                else
                puts "Opcion incorrecta", opc
            end
        end
        
        # Método que implementa las diferentes operaciones posibles en sus diferentes modos de ejecución.
        def ejecucion
            case @operation
                when :mostrar
                    raise RuntimeError , 'ERROR en el numero de operandos' unless @operands.size() == 1
                    
                    @result = @operands[0] # Matriz densa
                    if(@result_mode == :dispersa)
                        @result = Matriz_Dispersa.densa_a_dispersa(@operands[0])
                    elsif(@result_mode == :correcion_auto)
                        if(@result.porcentaje_nulos > 0.6) # Pasar a dispersa si tiene más de un 60% de elementos nulos
                            @result = Matriz_Dispersa.densa_a_dispersa(@operands[0])
                        end
                    end
                
                    if(@mode == :console)
                        puts @result.to_s
                    elsif(@mode == :file)
                        File.open('resultado.txt', 'w') { |file| file.write(@result.to_s) }
                    end
                    
                when :suma
                    raise RuntimeError , 'ERROR en el numero de operandos' unless @operands.size() == 2
                    
                    @result = @operands[0] + @operands[1] # Matriz densa
                    if(@result_mode == :dispersa or (@result_mode == :correccion_auto and @result.porcentaje_nulos >= 0.6))
                        @result = Matriz_Dispersa.densa_a_dispersa(@result)
                    end
                    
                    if(@mode == :console)
                        puts @result.to_s
                    elsif(@mode == :file)
                        File.open('resultado.txt', 'w') { |file| file.write(@result.to_s) }
                    end
                    
                when :resta
                    raise RuntimeError , 'ERROR en el numero de operandos' unless @operands.size() == 2
                    
                    @result = @operands[0] - @operands[1] # Matriz densa
                    if(@result_mode == :dispersa or (@result_mode == :correccion_auto and @result.porcentaje_nulos >= 0.6))
                        @result = Matriz_Dispersa.densa_a_dispersa(@result)
                    end
                    
                    if(@mode == :console)
                        puts @result.to_s
                    elsif(@mode == :file)
                        File.open('resultado.txt', 'w') { |file| file.write(@result.to_s) }
                    end
                    
                when :producto
                    raise RuntimeError , 'ERROR en el numero de operandos' unless @operands.size() == 2
                    
                    @result = @operands[0] * @operands[1] # Matriz densa
                    if(@result_mode == :dispersa or (@result_mode == :correccion_auto and @result.porcentaje_nulos >= 0.6))
                        @result = Matriz_Dispersa.densa_a_dispersa(@result)
                    end
                    
                    if(@mode == :console)
                        puts @result.to_s
                    elsif(@mode == :file)
                        File.open('resultado.txt', 'w') { |file| file.write(@result.to_s) }
                    end
                else
                    puts "Opcion incorrecta", @operation
            end
        end
    end
end

    