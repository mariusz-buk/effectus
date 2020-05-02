unit inifiles;
{ unit for reading and writing configuration files }
{ Version 1.0b by Raik Niemann ( mailto:raik.niemann@fh-stralsund.de ) }
{ Homepage : http://www.fh-stralsund.de/~seraniem/inifiles/index.html }
{$MODE OBJFPC}

interface
uses classes,sysutils;

TYPE
  { Declaration of a section }
  pSection = ^TSection;
  TSection = record
	name : shortstring;		// Section name
	data : TStringList;		// Pointer to a string list for "<key>=<value>"
  end;
  { Declaration of an Ini-File class }
  TIniFile = class
	private
	  FFile : text;
	  Sections : TList;
	  function GetSection( ASection : shortstring ) : pSection;
	  function GetKey( Line : string ) : shortstring;
	  function GetValue( Line : string ) : string;
	public
	  constructor Create( FileName : string );
	  destructor Free;
	  procedure Clear;
	  { Section handling }
	  function NewSection( ASection : shortstring ) : pSection;
	  procedure DeleteSection( ASection : shortstring );
	  function SectionExists( ASection : shortstring ) : boolean;
	  procedure SectionList( var AList : TStringList );
	  function SectionCount : integer;
	  { value handling }
	  function WriteString( ASection, AKey : shortstring; AValue : string ) : boolean;
	  function ReadString( ASection, AKey : shortstring; Default : string ) : string;
	  function WriteInteger( ASection, AKey : shortstring; AValue : integer ) : boolean;
	  function ReadInteger( ASection, AKey : shortstring; Default : integer ) : integer;
	  function WriteBool( ASection, AKey : shortstring; AValue : boolean ) : boolean;
	  function ReadBool( ASection, AKey : shortstring; Default : boolean ) : boolean;
	  function WriteFloat( ASection, AKey : shortstring; AValue : real ) : boolean;
	  function ReadFloat( ASection, AKey : shortstring; Default : real ) : real;
	  function KeyExists( ASection, AKey : shortstring ) : boolean;
	  function ValueCount( ASection : shortstring ) : integer;
	  procedure ValueList( var AList : TStringList; ASection : shortstring );
	  procedure KeyList( var AList : TStringList; ASection : shortstring );
	  function DeleteKey( ASection, AKey : shortstring ) : boolean;
	  { file handling }
	  function WriteIniFile : boolean;
	  function ReadIniFile : boolean;
  end;

implementation

{ Implementation }
  constructor TIniFile.Create( FileName : string );
  begin
	Sections:=TList.Create;
	if FileName <> '' then Assign( FFile, FileName );
  end;
  
  destructor TIniFile.Free;
  begin
	Clear;
	if assigned( Sections ) then Sections.Destroy;
  end;
  
  procedure TIniFile.Clear;
  { Clears all section and all data in the sections }
  var i			: integer;
	  Section	: pSection;
  begin
	for i:=SectionCount downto 1 do begin
	  Section:=Sections[i-1];
	  if assigned( Section ) then begin
		if assigned( Section^.data ) then Section^.data.Destroy;
		dispose( Section );
	  end;
	end;
  end;
  
{ Section handling }
  
  function TIniFile.SectionExists( ASection : shortstring ) : boolean;
  { Returns true if the section ASection exists, case-insensitive }
  var Section 	: pSection;
	  i			: integer;
  begin
	Result:=false;
	ASection:=AnsiUpperCase( ASection );
	if assigned( Sections ) then
	  for i:=1 to Sections.Count do begin
		Section:=Sections.Items[i-1];
		if assigned( Section ) then
		  if AnsiUpperCase( Section^.name ) = ASection then begin
			Result:=true;
			exit;
		  end;
	  end;
  end;
  
  function TIniFile.SectionCount : integer;
  { Returns the number of sections stored in the memory }
  begin
	Result:=Sections.count;
  end;
  
  function TIniFile.GetSection( ASection : shortstring ) : pSection;
  { Returns the handle of a section in the memory, case-insensitive }
  { If the section does not exists, it returns NIL }
  var Section : pSection;
	  i		  : integer;
  begin
	Result:=NIL;
	ASection:=AnsiUpperCase( ASection );
	if assigned( Sections ) then
	  for i:=1 to Sections.Count do begin
		Section:=Sections.Items[i-1];
		if assigned( Section ) then
		  if AnsiUpperCase( Section^.name ) = ASection then begin
			Result:=Section;
			exit;
		  end;
	  end;
  end;
  
  function TIniFile.NewSection( ASection : shortstring ) : pSection;
  { Adds a new section to the section list in the memory }
  { If the section can not be added, it returns NIL }
  var Section : pSection;
  begin
	Result:=NIL;
	if (not SectionExists( ASection )) and (ASection <> '' ) then begin
	  try
		new( Section );
		Section^.name:=ASection;
		Section^.data:=NIL;
	  finally
		Sections.Add( Section );
		Result:=Section;
	  end;
	end;
  end;
  
  procedure TIniFile.DeleteSection( ASection : shortstring );
  { Deletes a section with its data from the section list }
  var Section : pSection;
  begin
	Section:=GetSection( ASection );
	if assigned( Section ) then begin
	  if assigned( Section^.data ) then Section^.data.Destroy;
	  Sections.Delete( Sections.IndexOf( Section ) );
	  dispose( Section );
	end;  
  end;

  procedure TIniFile.SectionList( VAR AList : TStringList );
  { Returns a string list with all section names }
  var Section	: pSection;
	  i			: integer;
  begin
	if assigned( AList ) then
	  for i:=1 to SectionCount do begin
		Section:=Sections.Items[i-1];
		if assigned( Section ) then AList.Add( Section^.name );
	  end;
  end;

{ Key-Value handling }
  
  function TIniFile.GetKey( Line : string ) : shortstring;
  { Internal private function to get the key from a string "<key>=<value>" }
  var SepPos : integer;
  begin
	Result:='';
	SepPos:=Pos( '=', Line );
	if SepPos > 0 then Result:=Copy( Line, 1, SepPos-1 );
  end;
  
  function TIniFile.GetValue( Line : string ) : string;
  { Internal private function to get the value from a string "<key>=<value>" }
  var SepPos : integer;
  begin
	Result:='';
	SepPos:=Pos( '=', Line );
	if SepPos > 0 then Result:=Copy( Line, SepPos+1, Length( Line ) );
  end;
  
  function TIniFile.WriteString( ASection, AKey : shortstring; AValue : string ) : boolean;
  { Adds new data ( "<key>=<value>", value=string ) to a section }
  { If the section does not exists the section will be created }
  { If the key exists the value will be overwritten }
  var Section : pSection;
	  data	  : TStringList;
  begin
	Result:=false;
	if (ASection = '' ) or (AKey = '') or (AValue = '' ) then exit;
	Section:=GetSection( ASection );
	if not assigned( Section ) then Section:=NewSection( ASection );
	if assigned( Section ) then begin
	  data:=Section^.data;
	  if not assigned( data ) then begin
		try
		  data:=TStringList.Create;
		  data.Sorted:=true;
		  data.Duplicates:=dupIgnore;
		  data.Add( AKey+'='+AValue );
		finally
		  Section^.data:=data;
		end;  
	  end else
		data.Values[AKey]:=AValue;
	  Result:=true;
	end;
  end;  

  function TIniFile.WriteInteger( ASection, AKey : shortstring; AValue : integer ) : boolean;
  { Adds new data ( "<key>=<value>", value=integer ) to a section }
  { If the section does not exists the section will be created }
  { If the key exists the value will be overwritten }
  begin
	Result:=WriteString( ASection, AKey, IntToStr( AValue ) );
  end;

  function TIniFile.WriteBool( ASection, AKey : shortstring; AValue : boolean ) : boolean;
  { Adds new data ( "<key>=<value>", value=boolean ) to a section }
  { If the section does not exists the section will be created }
  { If the key exists the value will be overwritten }
  const BoolValues : array[boolean] of shortstring = ( 'false', 'true' );
  begin
	Result:=WriteString( ASection, AKey, BoolValues[AValue] );
  end;
  
  function TIniFile.WriteFloat( ASection, AKey : shortstring; AValue : Real ) : boolean;
  { Adds new data ( "<key>=<value>", value=float ) to a section }
  { If the section does not exists the section will be created }
  { If the key exists the value will be overwritten }
  begin
	Result:=WriteString( ASection, AKey, FloatToStr( AValue ) );
  end;
  
  function TIniFile.ReadString( ASection, AKey : shortstring; Default : string ) : string;
  { Reads a string value from a section ( "<key>=<value>", value=string ) }
  { If the section or the key do not exist the Default string will be returned }
  var Section : pSection;
	  data	  : TStringList;
  begin
	Result:=Default;
	Section:=GetSection( ASection );
	if assigned( Section ) then begin
	  data:=Section^.data;
	  if assigned( data ) then
		if KeyExists( ASection, AKey ) then 
		  Result:=data.Values[AKey];
	end;
  end;
  
  function TIniFile.ReadInteger( ASection, AKey : shortstring; Default : integer ) : integer;
  { Reads a string value from a section ( "<key>=<value>", value=integer ) }
  { If the section or the key do not exist the Default string will be returned }
  begin
	Result:=StrToIntDef( ReadString( ASection, AKey, IntToStr( Default ) ), Default );
  end;
  
  function TIniFile.ReadBool( ASection, AKey : shortstring; Default : boolean ) : boolean;
  var Value : shortstring;
  begin
	Result:=Default;
	Value:=ReadString( ASection, AKey, '' );
	if Value <> '' then begin
	  if AnsiUpperCase( Value ) = 'TRUE' then
		Result:=true
	  else
		if AnsiUpperCase( Value ) = 'FALSE' then
		  Result:=false;
	end;
  end;
  

  function TIniFile.ReadFloat( ASection, AKey : shortstring; Default : real ) : real;
  { Reads a string value from a section ( "<key>=<value>", value=float ) }
  { If the section or the key do not exist the Default string will be returned }
  var Value : string;
  begin
	Result:=Default;
	Value:=ReadString( ASection, AKey, FloatToStr( Default ) );
	try
	  Result:=StrToFloat( Value );
	except
	  Result:=Default;
	end;
  end;
  
  function TIniFile.KeyExists( ASection, AKey : shortstring ) : boolean;
  { Returns true if the key AKey ( "<key>=<value>" ) in the section ASection }
  { exists; false otherwise }
  var Section 	: pSection;
	  i			: integer;
  begin
	Result:=false;
	Section:=GetSection( ASection );
	if assigned( Section ) then
	  if assigned( Section^.data ) then
		for i:=1 to Section^.data.count do begin
		  if GetKey( Section^.data.Strings[i-1] ) = AKey then begin
			Result:=true;
			exit;
		  end;
		end;
  end;
  
  function TIniFile.ValueCount( ASection : shortstring ) : integer;
  { Returns the number of key-values-pairs in the section ASection }
  { Returns -1 if the section ASection does not exists }
  var Section : pSection;
  begin
	Result:=-1;
	Section:=GetSection( ASection );
	if assigned( Section ) then
	  if assigned( Section^.data ) then
		Result:=Section^.data.count;
  end;
  
  procedure TIniFile.ValueList( var AList : TStringList; ASection : shortstring );
  { Returns a string list with all values ( "<key>=<value>" ) in the section ASection }
  var Section	: pSection;
	  i			: integer;
  begin
	if assigned( AList ) then begin
	  Section:=GetSection( ASection );
	  if assigned( Section ) then
		if assigned( Section^.data ) then
		  for i:=1 to Section^.data.count do
			AList.Add( GetValue( Section^.data.Strings[i-1] ));
	end;
  end;
  
  procedure TIniFile.KeyList( var AList : TStringList; ASection : shortstring );
  { Returns a string list with all keys ( "<key>=<value>" ) in the section ASection }
  var Section	: pSection;
	  i			: integer;
  begin
	if assigned( AList ) then begin
	  Section:=GetSection( ASection );
	  if assigned( Section ) then
		if assigned( Section^.data ) then
		  for i:=1 to Section^.data.count do
			AList.Add( GetKey( Section^.data.Strings[i-1] ));
	end;
  end;
  
  function TIniFile.DeleteKey( ASection, AKey : shortstring ) : boolean;
  { Delete the key <AKey> in the section <ASection> }
  var Section 	: pSection;
	  i			: integer;
  begin
	Result:=false;
	Section:=GetSection( ASection );
	if assigned( Section ) then
	  if assigned( Section^.data ) then
		for i:=1 to Section^.data.count do begin
		  if GetKey( Section^.data.Strings[i-1] ) = AKey then begin
			Result:=true;
			Section^.data.Delete( i-1 );
			exit;
		  end;
		end;
  end;
  
{ file handling }
  
  function TIniFile.WriteIniFile : boolean;
  { Writes all sections with its key-value-pairs ( "<key>=<value>" ) into a }
  { text file }
  var Section 	: pSection;
	  i,j		: integer;
  begin
	Result:=false;
	try
	  ReWrite( FFile );
	  for i:=1 to SectionCount do begin
		Section:=Sections[i-1];
		if assigned( Section ) then begin
		  WriteLn( FFile, '['+Section^.name+']' );
		  for j:=1 to ValueCount( Section^.name ) do
			WriteLn( FFile, '  ', Section^.data.Strings[j-1] );
		  WriteLn( FFile );
		end;
	  end;
	  Close( FFile );
	finally
	  Result:=true;
	end;
  end;
  
  function TIniFile.ReadIniFile : boolean;
  { Reads sections with its data from a text file into the memory }
  var Line		  	: string;
	  SectionName 	: shortstring;
	  SepPos		: integer;
  begin
	Result:=false;
	Clear;
	SectionName:='';
	try
	  Reset( FFile );
	  while not eof( FFile ) do begin
		ReadLn( FFile, Line );
		Line:=Trim( Line );
		// New Section ?
		if (LeftStr( Line, 1 ) = '[') and (RightStr( Line,1 ) = ']') then begin
		  SectionName:=Copy( Line, 2, Length(Line)-2 );
		  if SectionName <> '' then
			NewSection( SectionName );
		end;
		// Value or comment ?
		if (LeftStr( Line,1 ) <> '#') and (LeftStr( Line,1 ) <> ';') then begin
		  SepPos:=Pos( '=', Line );
		  if SepPos > 0 then
			WriteString( SectionName, Copy( Line, 1, SepPos-1 ), Copy( Line, SepPos+1, Length( Line )) );
		end;
	  end;
	finally
	  Result:=true;
	end;
  end;
  
end.