module Db
  class Table
    def initialize(name:, logger:, indexes: [])
      @name = name.to_sym
      @indexes = indexes
      @records = {}

      @logger = logger
    end

    def all
      @records.values
    end

    def find(id:)
      record = @records[id]
      raise "record #{id} not found in table #{@name}" unless record

      record.tap { @logger.info("found record #{id} in table #{@name}") }
    end

    def find_by(**attributes)
      @records.values.find { |record|
      record.attributes.slice(*attributes.keys) == attributes 
    }
    end

    def insert(record:)
      unless find_by(record.attributes.slice(*@indexes)).nil?
        raise "record already exist with indexes #{@indexes} in table #{@name} (#{record.attributes.slice(*@indexes)})"
      end

      @records[record.id] = record.tap { @logger.info("added record to #{@name} table: #{record.attributes}") }
    end

    def update(record:)
      raise "record does not exist: table #{@name}, id #{record.id}" unless @records[record.id]

      @records[record.id] = record.tap { @logger.info("updated record on #{@name} table: #{record.attributes}") }
    end

    def delete(id:)
      raise "record does not exist: table #{@name}, id #{id}" unless @records[id]

      @records.delete(id).tap { @logger.info("deleted record #{id} from table #{@name}") }
    end
  end
end
