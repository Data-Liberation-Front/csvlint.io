require 'stored_csv'

class ChunksController < ApplicationController

  layout nil

      #GET /chunk
      def show
        #chunk folder path based on the parameters
        dir = "/tmp/#{params[:resumableIdentifier]}"
        #chunk path based on the parameters
        chunk = "#{dir}/#{params[:resumableFilename]}.part#{params[:resumableChunkNumber]}"

        if File.exists?(chunk)
          #Let resumable.js know this chunk already exists
          render :nothing => true, :status => 200
        else
          #Let resumable.js know this chunk doesnt exists and needs to be uploaded
          render :nothing => true, :status => 404
        end

      end

      #POST /chunk
      def create

        #chunk folder path based on the parameters
        dir = "/tmp/#{params[:resumableIdentifier]}"
        #chunk path based on the parameters
        chunk = "#{dir}/#{params[:resumableFilename]}.part#{params[:resumableChunkNumber]}"


        #Create chunks directory when not present on system
        if !File.directory?(dir)
          FileUtils.mkdir(dir, :mode => 0700)
        end

        #Move the uploaded chunk to the directory
        FileUtils.mv params[:file].tempfile, chunk

        #Concatenate all the partial files into the original file

        currentSize = params[:resumableChunkNumber].to_i * params[:resumableChunkSize].to_i
        filesize = params[:resumableTotalSize].to_i

        #When all chunks are uploaded
        if (currentSize + params[:resumableCurrentChunkSize].to_i) >= filesize

          #Create a target file
          target_file = Tempfile.new(params[:resumableFilename])

          for i in 1..params[:resumableChunkNumber].to_i
            #Select the chunk
            chunk = File.open("#{dir}/#{params[:resumableFilename]}.part#{i}", 'r').read

            #Write chunk into target file
            chunk.each_line do |line|
              target_file.write(line)
            end

            #Deleting chunk
            FileUtils.rm "#{dir}/#{params[:resumableFilename]}.part#{i}", :force => true
          end

          target_file.rewind

          stored_csv = StoredCSV.save(target_file, params[:resumableFilename])

          render json: { id: stored_csv.id.to_s }, :status => 200
        else
          render :nothing => true, :status => 200
        end
      end

end
