<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- ********************************************************************
	 ********************************************************************
	 Copyright 2010-2021, Regina Obe
	 License: BSD
	 Purpose: This is an xsl transform that generates file postgis_aggs_mm.xml which
	 includes index listing of aggregate functions and mm /sql compliant functions as well as what is new in each release
	 It uses xml reference sections from reference.xml to then
	 be processed by doc book
	 ******************************************************************** -->
	<xsl:output method="xml" indent="yes" encoding="utf-8" />

	<!-- We deal only with the reference chapter -->
	<xsl:template match="/">
		<xsl:apply-templates select="/book/chapter[@id='reference']" />
	</xsl:template>

	<xsl:template match="//chapter">
	<chapter id="PostGIS_Special_Functions_Index">
		<title>PostGIS関数索引</title>
		<sect1 id="PostGIS_Aggregate_Functions">
			<title>PostGIS集約関数</title>
			<para>次に示す関数は、PostGISが提供する空間集約関数です。sumやaverageといった他のSQL集約関数のように使います。</para>
			<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
			<xsl:for-each select='//refentry'>
				<xsl:sort select="refnamediv/refname"/>
				<xsl:variable name='comment'>
					<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
				</xsl:variable>
				<xsl:variable name="refid">
					<xsl:value-of select="@id" />
				</xsl:variable>
				<xsl:variable name="refname">
					<xsl:value-of select="refnamediv/refname" />
				</xsl:variable>

			<!-- For each function prototype if it takes a geometry set then catalog it as an aggregate function  -->

						<xsl:if test=".//paramdef[contains(type,' set')] or .//paramdef[contains(type,'geography set')] or
						.//paramdef[contains(type,'raster set')]">
							 <listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:if>
				</xsl:for-each>
			</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_Window_Functions">
			<title>PostGISウィンドウ関数</title>
			<para>次に示す関数は、PostGISが提供する空間ウィンドウ関数です。row_numer(), lead(), lag()等のような他のSQLウィンドウ関数のように使います。全ての関数で、SQLのOVER()句が必要です。</para>
            <xsl:if test="//funcprototype[contains(paramdef/type,' winset')]">
			<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
			<xsl:for-each select='//refentry'>
				<xsl:sort select="refnamediv/refname"/>
				<xsl:variable name='comment'>
					<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
				</xsl:variable>
				<xsl:variable name="refid">
					<xsl:value-of select="@id" />
				</xsl:variable>
				<xsl:variable name="refname">
					<xsl:value-of select="refnamediv/refname" />
				</xsl:variable>

			<!-- For each function prototype if it takes a geometry set then catalog it as an aggregate function  -->
				<xsl:for-each select="refsynopsisdiv/funcsynopsis/funcprototype">
					<xsl:choose>
						<xsl:when test="contains(paramdef/type,' winset')">
							 <listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</xsl:for-each>
			</itemizedlist>
            </xsl:if>
		</sect1>

		<sect1 id="PostGIS_SQLMM_Functions">
			<title>PostGIS SQL-MM準拠関数</title>
			<para>次に示す関数は、SQL/MM 3標準に準拠したPostGIS関数です。</para>
			<note>
			  <para>SQL-MMでは、全てのジオメトリコンストラクタのデフォルトSRIDを0としています。PostGISは-1としています (訳注: 2.0.0以降は0です)。</para>
			</note>
			<para>The functions given below are PostGIS functions that conform to the SQL/MM 3 standard</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>

			<!-- For each section if there is note that it implements SQL/MM catalog it -->
						<xsl:for-each select="refsection">
							<xsl:for-each select="para">
								<xsl:choose>
									<xsl:when test="contains(.,'implements the SQL/MM')">
										<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refid" /></link> - <xsl:value-of select="$comment" /> <xsl:value-of select="." /></simpara></listitem>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_GeographyFunctions">
			<title>PostGISジオグラフィ対応関数</title>
			<para>次に示す関数と演算子は、<link linkend="PostGIS_Geography">ジオグラフィ</link>データ型を入力または出力に取るPostGIS関数/演算子です。</para>
			<note><para>(T)の付いた関数はネイティブなジオグラフィ関数ではなく、実行時にST_Transformを使ってジオメトリとの変換を行います。結果として、日付変更線や極を超えたり、ひとつのUTMゾーンではカバーできない巨大なジオメトリを使用する場合に、予期しない挙動になることがあります。基本的な変換としては、UTMが望ましいですが、ランベルト正積方位図法(北/南)、最悪のシナリオでメルカトルに頼ります。</para></note>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- If at least one proto function accepts or returns a geography -->
					<xsl:choose>
						<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'geography') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geography')">
							<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_RasterFunctions">
			<title>PostGISラスタ機能関数</title>
			<para>次に示す関数と演算子は、<xref linkend="raster" />データ型を入力または出力に取るPostGIS関数/演算子です。アルファベット順に示します。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- If at least one proto function accepts or returns a geography -->
					<xsl:choose>
						<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'raster') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'raster')">
							<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				</itemizedlist>
		</sect1>


		<sect1 id="PostGIS_Geometry_DumpFunctions">
			<title>PostGISジオメトリ/ジオグラフィ/ラスタのダンプ関数</title>
			<para>次に示す関数は、<link linkend="geometry_dump">geometry_dump</link>または<link linkend="geomval">geomval</link>データ型の集合または単一データを入力または出力に取るPostGIS関数です。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- If at least one proto function accepts or returns a geography -->
					<xsl:choose>
						<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'geometry_dump') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geometry_dump') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geomval')">
							<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_BoxFunctions">
			<title>PostGISボックス関数</title>
			<para>次に示す関数は、PostGIS空間型のbox系の型を入力または出力に取るPostGIS関数です。ボックス系には<link linkend="box2d_type">box2d</link>と<link linkend="box3d_type">box3d</link>があります。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- If at least one proto function accepts or returns a geography -->
					<xsl:choose>
						<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'box') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'box')">
							<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_3D_Functions">
			<title>3次元対応PostGIS関数</title>
			<para>次に示す関数は、Zインデクスを放り出さないPostGIS関数です。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>

			<!-- For each section if there is note that it supports 3d catalog it -->
						<xsl:for-each select="refsection">
							<xsl:for-each select="para">
								<xsl:choose>
									<xsl:when test="contains(.,'This function supports 3d')">
										<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refid" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_Curved_GeometryFunctions">
			<title>PostGIS曲線ジオメトリ対応関数</title>
			<para>次に示す関数は、CIRCULARSTRING, CURVEDPOLYGON等の曲線ジオメトリ型が使えるPostGIS関数です。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- For each section if there is note that it implements Circular String catalog it -->
						<xsl:for-each select="refsection">
							<xsl:for-each select="para">
								<xsl:choose>
									<xsl:when test="contains(.,'supports Circular Strings')">
										<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_PS_GeometryFunctions">
			<title>PostGIS多面体サーフェス対応関数</title>
			<para>次に示す関数は、POLYHEDRALSURFACE, POLYHEDRALSURFACEMジオメトリが使えるPostGIS関数です。</para>
				<itemizedlist>
			<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>
					<xsl:variable name="refname">
						<xsl:value-of select="refnamediv/refname" />
					</xsl:variable>

			<!-- For each section if there is note that it supports Polyhedral surfaces catalog it -->
						<xsl:for-each select="refsection">
							<xsl:for-each select="para">
								<xsl:choose>
									<xsl:when test="contains(.,'supports Polyhedral')">
										<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="$comment" /></simpara></listitem>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each>
				</xsl:for-each>
				</itemizedlist>
		</sect1>

		<sect1 id="PostGIS_TypeFunctionMatrix">
			<xsl:variable name='matrix_checkmark'><![CDATA[<inlinemediaobject><imageobject><imagedata fileref='images/matrix_checkmark.png' /></imageobject></inlinemediaobject>]]></xsl:variable>
			<xsl:variable name='matrix_transform'><![CDATA[<inlinemediaobject><imageobject><imagedata fileref='images/matrix_transform.png' /></imageobject></inlinemediaobject>]]></xsl:variable>
			<xsl:variable name='matrix_autocast'><![CDATA[<inlinemediaobject><imageobject><imagedata fileref='images/matrix_autocast.png' /></imageobject></inlinemediaobject>]]></xsl:variable>
			<xsl:variable name='matrix_sfcgal_required'><![CDATA[<inlinemediaobject><imageobject><imagedata fileref='images/matrix_sfcgal_required.png' /></imageobject></inlinemediaobject>]]></xsl:variable>
			<xsl:variable name='matrix_sfcgal_enhanced'><![CDATA[<inlinemediaobject><imageobject><imagedata fileref='images/matrix_sfcgal_enhanced.png' /></imageobject></inlinemediaobject>]]></xsl:variable>

			<title>PostGIS関数対応マトリクス</title>

			<para>次に示す表は、アルファベット順に並べたPostGIS空間関数と、動作する空間タイプの種類、対応しようとしているOGC/SQL準拠を示しています。</para>
			<para><itemizedlist>
				<listitem><simpara><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/> は、ネイティブで、その型と派生型とに対応しています。</simpara></listitem>
				<listitem><simpara><xsl:value-of select="$matrix_transform" disable-output-escaping="yes"/> は、動作しますが、ジオメトリにキャストして「最善のSRID」に投影変換したうえでジオグラフィに戻す、組み込み変換キャストを使います。大きな面積の領域や、極にある領域については、予期しない結果になることがありますし、浮動小数点数のごみを蓄積することがあります。</simpara></listitem>
				<listitem><simpara><xsl:value-of select="$matrix_autocast" disable-output-escaping="yes"/> は、直接的な対応でなくbox3dへの変換といった他からの自動キャストで動作します。</simpara></listitem>
				<listitem><simpara><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/> は、PostGISをSFCGAL対応でコンパイルした場合にのみ利用可能な関数です。</simpara></listitem>
				<listitem><simpara><xsl:value-of select="$matrix_sfcgal_enhanced" disable-output-escaping="yes"/> は、PostGISをSFCGAL対応でコンパイルした場合には、SFCGALが提供し、その他の場合には、GEOSまたは組み込み関数で対応します。</simpara></listitem>
				<listitem><simpara>geom - 基本的な2次元ジオメトリ (x,y)に対応しています。</simpara></listitem>
				<listitem><simpara>geog - 基本的な2次元ジオグラフィ (x,y)に対応しています。</simpara></listitem>
				<listitem><simpara>2.5D - 3次元/4次元 (ZまたはM座標を持つ)空間内の基本的な2次元ジオメトリに対応しています。</simpara></listitem>
				<listitem><simpara>PS - 多面体サーフェス (Polyhedral Surface)に対応しています。</simpara></listitem>
				<listitem><simpara>T - 三角形と不規則三角網 (TIN)に対応しています。</simpara></listitem>
				</itemizedlist>
			</para>

			<para>
				<informaltable frame='all'>
					<tgroup cols='8' align='left' colsep='1' rowsep='1'>
						<colspec colname='function' align='left'/>
						<colspec colname='geometry' align='center'/>
						<colspec colname='geography' align='center'/>
						<colspec colname='25D' align='center'/>
						<colspec colname='Curves' align='center'/>
						<colspec colname='SQLMM' align='center' />
						<colspec colname='PS' align='center' />
						<colspec colname='T' align='center' />
						<thead>
						  <row>
							<entry>関数</entry>
							<entry>geom</entry>
							<entry>geog</entry>
							<entry>2.5D</entry>
							<entry>Curves</entry>
							<entry>SQL MM</entry>
							<entry>PS</entry>
							<entry>T</entry>
						  </row>
						</thead>
						<tbody>
						<!-- Exclude PostGIS types, management functions, long transaction support, or exceptional functions from consideration  -->
						<!-- leaving out operators in an effor to try to fit on one page -->
						<xsl:for-each select="sect1[not(@id='PostGIS_Types' or @id='Management_Functions' or @id='Long_Transactions_Support' or @id='Exceptional_Functions')]/refentry">
							<xsl:sort select="@id"/>
							<xsl:variable name='comment'>
								<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
							</xsl:variable>
							<xsl:variable name="refid">
								<xsl:value-of select="@id" />
							</xsl:variable>
							<xsl:variable name="refname">
								<xsl:value-of select="refnamediv/refname" />
							</xsl:variable>

							<row>
								<!-- Display name of function and link to it -->
								<entry><link linkend="{$refid}"><xsl:value-of select="$refname" /></link></entry>
								<!-- If at least one proto function accepts or returns a geometry -->
								<xsl:choose>
									<!-- direct support -->
									<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'geometry') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geometry')">
										<entry><xsl:choose><xsl:when test="contains(.,'needs SFCGAL')"><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/></xsl:when><xsl:otherwise><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></xsl:otherwise></xsl:choose></entry>
									</xsl:when>
									<!-- support via autocast -->
									<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'box') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'box')">
										<entry><xsl:value-of select="$matrix_autocast" disable-output-escaping="yes"/></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
								<!-- If at least one proto function accepts or returns a geography -->
								<xsl:choose>
									<!-- Support via geometry transform hack -->
									<xsl:when test="(contains(refsynopsisdiv/funcsynopsis,'geography') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geography')) and contains($comment,'(T)')">
										<entry><xsl:value-of select="$matrix_transform" disable-output-escaping="yes"/></entry>
									</xsl:when>
									<!-- direct support -->
									<xsl:when test="contains(refsynopsisdiv/funcsynopsis,'geography') or contains(refsynopsisdiv/funcsynopsis/funcprototype/funcdef,'geography')">
										<entry><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>

								<!-- If at least one paragraph contains support 3d -->
								<xsl:choose>
									<!-- supports -->
									<xsl:when test="contains(.,'This function supports 3d')">
										<!-- if 3d denote if it needs sfcgal -->
										<entry><xsl:choose><xsl:when test="contains(.,'needs SFCGAL')"><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/></xsl:when>
										<xsl:when test="contains(.,'provided by SFCGAL')"><xsl:value-of select="$matrix_sfcgal_enhanced" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></xsl:otherwise></xsl:choose></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
								<!-- Support for Curve -->
								<xsl:choose>
									<!-- supports -->
									<xsl:when test="contains(.,'supports Circular Strings')">
										<entry><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
								<!-- SQL MM compliance -->
								<xsl:choose>
									<!-- supports -->
									<xsl:when test="contains(.,'implements the SQL/MM')">
										<entry><xsl:choose><xsl:when test="contains(.,'needs SFCGAL')"><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/></xsl:when>
										<xsl:when test="contains(.,'provided by SFCGAL')"><xsl:value-of select="$matrix_sfcgal_enhanced" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></xsl:otherwise></xsl:choose></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
							<!-- Polyhedral surface support -->
								<xsl:choose>
									<!-- supports -->
									<xsl:when test="contains(.,'Polyhedral')">
										<entry><xsl:choose><xsl:when test="contains(.,'needs SFCGAL')"><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/></xsl:when>
										<xsl:when test="contains(.,'provided by SFCGAL')"><xsl:value-of select="$matrix_sfcgal_enhanced" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></xsl:otherwise></xsl:choose></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
							<!-- Triangle and TIN surface support -->
								<xsl:choose>
									<!-- supports -->
									<xsl:when test="contains(.,'Triang')">
										<entry><xsl:choose><xsl:when test="contains(.,'needs SFCGAL')"><xsl:value-of select="$matrix_sfcgal_required" disable-output-escaping="yes"/></xsl:when>
										<xsl:when test="contains(.,'provided by SFCGAL')"><xsl:value-of select="$matrix_sfcgal_enhanced" disable-output-escaping="yes"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="$matrix_checkmark" disable-output-escaping="yes"/></xsl:otherwise></xsl:choose></entry>
									</xsl:when>
									<!-- no support -->
									<xsl:otherwise>
										<entry></entry>
									</xsl:otherwise>
								</xsl:choose>
							</row>
						</xsl:for-each>
						</tbody>
					</tgroup>
		</informaltable>
		</para>
	   </sect1>

	   <sect1 id="NewFunctions">
			<title>新規作成/機能強化/変更されたPostGIS関数</title>
			<sect2 id="NewFunctions_3_2">
				<title>PostGIS 3.2で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
        <xsl:if test="//para[contains(text(),'Availability: 3.2')]">
				<para>PostGIS 3.2で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 3.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
        </xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 3.2')]">
				<para>PostGIS 3.2で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 3.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
			</xsl:if>

			<para>PostGIS 3.2で変更された関数</para>
				<xsl:if test="//para[contains(text(),'Changed: 3.2')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 3.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>

			<sect2 id="NewFunctions_3_1">
				<title>PostGIS 3.1で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
                <xsl:if test="//para[contains(text(),'Availability: 3.1')]">
				<para>PostGIS 3.1で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 3.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 3.1')]">
				<para>PostGIS 3.1で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 3.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
			</xsl:if>


			<para>PostGIS 3.1で変更された関数</para>
				<xsl:if test="//para[contains(text(),'Changed: 3.1')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 3.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>

			<sect2 id="NewFunctions_3_0">
				<title>PostGIS 3.0で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
                <xsl:if test="//para[contains(text(),'Availability: 3.0')]">
				<para>PostGIS 3.0で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 3.0')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 3.0')]">
				<para>PostGIS 3.0で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 3.0')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
			</xsl:if>


			<para>PostGIS 3.0で変更された関数</para>
				<xsl:if test="//para[contains(text(),'Changed: 3.0')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 3.0')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>

            <sect2 id="NewFunctions_2_5">
				<title>PostGIS 2.5で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
                <xsl:if test="//para[contains(text(),'Availability: 2.5')]">
				<para>PostGIS 2.5で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.5')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 2.5')]">
				<para>PostGIS 2.5で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.5')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>


				<para>PostGIS 2.5で変更された関数</para>
				<xsl:if test="//para[contains(text(),'Changed: 2.5')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 2.5')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>
			</sect2>

            <sect2 id="NewFunctions_2_4">
				<title>PostGIS 2.4で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
                <xsl:if test="//para[contains(text(),'Availability: 2.4')]">
				<para>PostGIS 2.4で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.4')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 2.4')]">
				<para>PostGIS 2.4で機能強化された関数</para>
				<para>全てのPostGIS集約関数はパラレル安全のラベル付けが施されます。これにより、並列処理を使用できるクエリプランで使うことができるようになります。</para>
				<para>PostGIS 2.4.1のpostgis_tiger_geocoderはTiger 2017データをロードするように設定されています。必要に応じて、zip code 5-digit tabulation (zcta)を<xref linkend="Loader_Generate_Nation_Script" />の一部としてロードすることができます。</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.4')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>


				<para>PostGIS 2.4で変更された関数</para>
				<para>全てのPostGIS集約関数はパラレル安全のラベル付けが施されます。これにより集約関数の削除と再作成が強制的に行われます。この際、ユーザ定義のビューまたはSQL関数がPostGIS集約関数に依っている場合に失敗することがあります。</para>
				<xsl:if test="//para[contains(text(),'Changed: 2.4')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 2.4')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

			</sect2>

			<sect2 id="NewFunctions_2_3">
				<title>PostGIS 2.3で新規作成/機能強化された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
                <note><para>PostGIS 2.3.0: PostgreSQL 9.6以上で、並列クエリに対応します。</para></note>
                <note><para>PostGIS 2.3.0:データベースのリストアにおける問題を低減するために、PostGISエクステンションの全ての関数に対してスキーマ修飾を可能にしました。</para></note>
                <note><para>PostGIS 2.3.0: PostgreSQL 9.4以上で、BRINインデックスに対応します。<xref linkend="brin_indexes" />を参照して下さい。</para></note>
                <note><para>PostGIS 2.3.0: Tigerジオコーダは、TIGER 2016データで動作するように更新されました。</para></note>
                <xsl:if test="//para[contains(text(),'Availability: 2.3')]">
				<para>PostGIS 2.3で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.3')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

                <xsl:if test="//para[contains(text(),'Enhanced: 2.3')]">
				<para>PostGIS 2.3で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.3')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
                </xsl:if>

			</sect2>

			<sect2 id="NewFunctions_2_2">
				<title>PostGIS 2.2で新規作成/機能強化された関数</title>
				<para>次に示す関数は、追加または機能強化されたPostGIS関数です。</para>
				
				<note><para>postgis_sfcgalは、現在はエクステンションとしてインストールできます。CREATE EXTENSION postgis_sfcgal;とします。</para></note>
				<note><para>PostGIS 2.2.0:Tigerジオコーダは、TIGER 2015データで動作するように更新されました。</para></note>
				<note><para>住所正規化のための address_standardizer, address_standardizer_data_us エクステンションの詳細情報については<xref linkend="Address_Standardizer" />を参照して下さい。</para></note>
				<note><para>トポロジの多くの関数は、性能向上のためにC関数で再記述されました。</para></note>
				<xsl:if test="//para[contains(text(),'Availability: 2.2')]">
				<para>PostGIS 2.2で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>

				 <xsl:if test="//para[contains(text(),'Enhanced: 2.2')]">
				<para>PostGIS 2.2で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>

			<xsl:if test="//para[contains(text(),'Changed: 2.2')]">
		 	<sect2 id="ChangedFunctions_2_2"><title>PostGIS 2.2で大幅に変更された関数</title>
				<para>次に示す関数は、PostGIS 2.2で、たぶん大幅に変更されたものです。これらを使用している場合には、既存のコードを確認する必要があるかも知れません。</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 2.2')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
			</sect2>
			</xsl:if>


			<sect2 id="NewFunctions_2_1">
				<title>PostGIS 2.1で新規作成/機能強化された関数</title>
				<para>次に示す関数は、追加または機能強化されたPostGIS関数です。</para>
				
				<note><para>トポロジの効率が改善されています。詳細情報については<xref linkend="Topology" />を参照して下さい。</para></note>
				<note><para>バグ訂正 (特にバンド外ラスタ)、多くの新しい関数 (しばしばユーザが共通のタスクを果たすために記述するコードを短くできます)、ラスタ機能における大規模の速度改善があります。詳細情報については<xref linkend="RT_reference" />を参照して下さい。</para></note>
				<note><para>PostGIS 2.1.0: Tigerジオコーダは、TIGER 2012データで動作するように更新されました。また、デバッグと格付け設定変更のために<varname>geocode_settings</varname>が追加され、ローダのロード量を抑制して、現在はロードするべきテーブルをダウンロードするだけになりました。PostGIS 2.1.1: Tigerジオコーダは、TIGER 2013データで動作するように更新されました。詳細情報については、<xref linkend="Tiger_Geocoder" />を参照して下さい。</para></note>

				<xsl:if test="//para[contains(text(),'Availability: 2.1')]">
				<para>PostGIS 2.1で新規作成された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 2.1')]">
				<para>PostGIS 2.1で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>

			</sect2>

			<xsl:if test="//para[contains(text(),'Changed: 2.1')]">
			<sect2 id="ChangedFunctions_2_1"><title>PostGIS 2.1で大幅に変更された関数</title>
				<para>次に示す関数は、PostGIS 2.1で、たぶん大幅に変更されたものです。これらを使用している場合には、既存のコードを確認する必要があるかも知れません。</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Changed: 2.1')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
			</sect2>
			</xsl:if>


			<sect2 id="NewFunctions_2_0">
				<title>PostGIS 2.0で新規作成/機能強化/変更された関数</title>
				<para>次に示す関数は、2.0リリースで新規作成/機能強化/大幅な変更 (<xref linkend="NewFunctions_2_0_Changed" />)がなされたPostGIS関数です。</para>
				<para>新ジオメトリタイプ: TINと多面体サーフェスが2.0で導入されました。</para>
				<note><para>トポロジ機能の大幅な改良がありました。詳細情報については<xref linkend="Topology" />を参照して下さい。</para></note>
				<note><para>PostGIS 2.0では、ラスタ型とラスタ機能がPostGISに統合されました。ここに一覧を出すには、新しいラスタ関数はあまりに多く、全ての関数が新しいので、有効なラスタ関数の詳細については<xref linkend="RT_reference" />を参照して下さい。2.0より前では、raster_columnsとraster_overviewsは実際のテーブルでした。2.0リリースでビューに変更されました。<varname>ST_AddRasterColumn</varname>等の関数は削除され、<xref linkend="RT_AddRasterConstraints"/>, <xref linkend="RT_DropRasterConstraints"/>に置き換えられました。結果として、ラスタテーブルを生成するアプリケーションは変更が必要になるかも知れなくなりました。</para></note>
				<note><para>Tigerジオコーダは、TIGER 2010センサスデータで動作するように更新され、PostGISの中核文書に入れられました。また、逆ジオコーダ関数が新規作成されました。詳細情報については<xref linkend="Tiger_Geocoder" />を参照して下さい。</para></note>

				<xsl:if test="//para[contains(text(),'Availability: 2.0')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="refnamediv/refname"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 2.0')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>

				<xsl:if test="//para[contains(text(),'Enhanced: 2.0')]">
				<para>PostGIS 2.0で機能強化された関数</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry   -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>
				<!-- For each section if there is note about enhanced in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para | */para">
									<xsl:choose>
										<xsl:when test="contains(.,'Enhanced: 2.0')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>

			<sect2 id="NewFunctions_2_0_Changed">
			       <title>PostGIS 2.0で変更された関数</title>
			       <para>次に示す関数は、PostGIS2.0で変更されたもので、アプリケーションの変更が必要になる場合があります。</para>
                    <note><para>ほとんどの非推奨関数は削除されました。これらは、1.2から文書には出ていないか、絶対に文書化されない内部関数です。文書に無い関数を使用している場合には、非推奨関数になっているか、非推奨になろうとしているか、内部関数の可能性があります。これらは避けるべきです。非推奨関数を使っているアプリケーションやツールの対応に関する詳細情報については<xref linkend="legacy_faq" />をご覧下さい。</para></note>
                    <note><para>ジオメトリのバウンディングボックスはfloat4から倍精度浮動小数点数 (float8)に変わりました。バウンディングボックス演算子を使う場合とバウンディングボックスからジオメトリへのキャストに影響が出ます。たとえば、ST_SetSRID(abbox)は、しばしば、以前の版ではビューポートクエリの答をわずかに変更する可能性がありますが、PostGIS 2.0以上では、それとは異なる、より精度の良い答えを返します。</para></note>
                    <note><para>hasnodata引数は、同じ意味ですがより目的がはっきり分かるexclude_nodata_valueに置き換えられました。</para></note>

					<xsl:if test="//para[contains(text(),'Changed: 2.0')]">
                    <itemizedlist>
                    <!-- Pull out the purpose section for each ref entry   -->
                        <xsl:for-each select='//refentry'>
                            <xsl:sort select="@id"/>
                            <xsl:variable name="refid">
                                <xsl:value-of select="@id" />
                            </xsl:variable>

                            <xsl:variable name="refname">
                                <xsl:value-of select="refnamediv/refname" />
                            </xsl:variable>
                    <!-- For each section if there is note about enhanced in this version -->
                                <xsl:for-each select="refsection">
                                    <xsl:for-each select="para | */para">
                                        <xsl:choose>
                                            <xsl:when test="contains(.,'Changed: 2.0')">
                                                <listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /></simpara></listitem>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:for-each>
                        </xsl:for-each>
                    </itemizedlist>
					</xsl:if>
             </sect2>

			<sect2 id="NewFunctions_1_5">

				<title>PostGIS 1.5で新規作成/機能強化/変更された関数</title>
				<xsl:if test="//para[contains(text(),'Availability: 1.5')]">
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

						<xsl:variable name="refname">
							<xsl:value-of select="refnamediv/refname" />
						</xsl:variable>


				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 1.5')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refname" /></link> - <xsl:value-of select="." /><xsl:text> </xsl:text> <xsl:value-of select="$comment" /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>
			<sect2 id="NewFunctions_1_4">
				<title>PostGIS 1.4で新規作成/機能強化/変更された関数</title>
				<para>次に示す関数は、新規作成または機能強化されたPostGIS関数です。</para>
				<xsl:if test="//para[contains(text(),'Availability: 1.4')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
					<xsl:for-each select='//refentry'>
						<xsl:sort select="@id"/>
						<xsl:variable name='comment'>
							<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
						</xsl:variable>
						<xsl:variable name="refid">
							<xsl:value-of select="@id" />
						</xsl:variable>

				<!-- For each section if there is note about availability in this version -->
							<xsl:for-each select="refsection">
								<xsl:for-each select="para|note">
									<xsl:choose>
										<xsl:when test="contains(.,'Availability: 1.4')">
											<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refid" /></link> - <xsl:value-of select="$comment" /> <xsl:text> </xsl:text><xsl:value-of select="." /></simpara></listitem>
										</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
					</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>
			<sect2 id="NewFunctions_1_3">
				<title>PostGIS 1.3で新規作成された関数</title>
				<para>次に示す関数は、新規作成されたPostGIS関数です。</para>
				<xsl:if test="//para[contains(text(),'Availability: 1.3')]">
				<itemizedlist>
				<!-- Pull out the purpose section for each ref entry and strip whitespace and put in a variable to be tagged unto each function comment  -->
				<xsl:for-each select='//refentry'>
					<xsl:sort select="@id"/>
					<xsl:variable name='comment'>
						<xsl:value-of select="normalize-space(translate(translate(refnamediv/refpurpose,'&#x0d;&#x0a;', ' '), '&#09;', ' '))"/>
					</xsl:variable>
					<xsl:variable name="refid">
						<xsl:value-of select="@id" />
					</xsl:variable>

				<!-- For each section if there is note about availability in this version -->
						<xsl:for-each select="refsection">
							<xsl:for-each select="para">
								<xsl:choose>
									<xsl:when test="contains(.,'Availability: 1.3')">
										<listitem><simpara><link linkend="{$refid}"><xsl:value-of select="$refid" /></link> - <xsl:value-of select="$comment" /> <xsl:text> </xsl:text><xsl:value-of select="." /></simpara></listitem>
									</xsl:when>
								</xsl:choose>
							</xsl:for-each>
						</xsl:for-each>
				</xsl:for-each>
				</itemizedlist>
				</xsl:if>
			</sect2>
		</sect1>

	</chapter>
	</xsl:template>

	<!--macro to pull out function parameter names so we can provide a pretty arg list prefix for each function -->
	<xsl:template name="listparams">
		<xsl:param name="func" />
		<xsl:for-each select="$func">
			<xsl:if test="count(paramdef/parameter) &gt; 0">args: </xsl:if>
			<xsl:for-each select="paramdef">
				<xsl:choose>
					<xsl:when test="count(parameter) &gt; 0">
						<xsl:value-of select="parameter" />
					</xsl:when>
				</xsl:choose>
				<xsl:if test="position()&lt;last()"><xsl:text>, </xsl:text></xsl:if>
			</xsl:for-each>
			<xsl:if test="count(paramdef/parameter) &gt; 0"> - </xsl:if>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
