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
          File.open("#{dir}/#{params[:resumableFilename]}","a") do |target|
            #Loop trough the chunks
            for i in 1..params[:resumableChunkNumber].to_i
              #Select the chunk
              chunk = File.open("#{dir}/#{params[:resumableFilename]}.part#{i}", 'r').read

              #Write chunk into target file
              chunk.each_line do |line|
                target << line
              end

              #Deleting chunk
              FileUtils.rm "#{dir}/#{params[:resumableFilename]}.part#{i}", :force => true
            end
            puts "File saved to #{dir}/#{params[:resumableFilename]}"
          end
        end

        render :nothing => true, :status => 200
      end

end
