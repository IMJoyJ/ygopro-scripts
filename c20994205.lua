--ナンバーズ・エヴァイユ
-- 效果：
-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。从额外卡组选4只「No.」超量怪兽（相同阶级最多1只）。「No.」数值和那4只的合计相同的1只「No.」超量怪兽当作超量召唤从额外卡组特殊召唤，把选的怪兽全部作为那只怪兽的超量素材。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「No.」超量怪兽不能特殊召唤。
function c20994205.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。从额外卡组选4只「No.」超量怪兽（相同阶级最多1只）。「No.」数值和那4只的合计相同的1只「No.」超量怪兽当作超量召唤从额外卡组特殊召唤，把选的怪兽全部作为那只怪兽的超量素材。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「No.」超量怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20994205.condition)
	e1:SetTarget(c20994205.target)
	e1:SetOperation(c20994205.activate)
	c:RegisterEffect(e1)
end
-- 筛选从额外卡组特殊召唤的怪兽，用于判定场上是否存在该类怪兽。
function c20994205.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动条件：自己场上不存在从额外卡组特殊召唤的怪兽，且对方场上存在至少1只从额外卡组特殊召唤的怪兽。
function c20994205.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上不存在从额外卡组特殊召唤的怪兽。
	return not Duel.IsExistingMatchingCard(c20994205.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上存在至少1只从额外卡组特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c20994205.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 筛选额外卡组中的「No.」超量怪兽，且拥有No.编号（可作为素材或特殊召唤对象）。
function c20994205.nofilter(c)
	-- 判定该卡是超量怪兽、属于「No.」卡且能获取No.编号。
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and aux.GetXyzNumber(c)
end
-- 筛选额外卡组中可被当作超量召唤特殊召唤的「No.」超量怪兽，且场上有空位可用。
function c20994205.spfilter(c,e,tp)
	return c20994205.nofilter(c)
		-- 判定该怪兽可被当作超量召唤特殊召唤，且额外卡组怪兽有可用的特殊召唤区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 子组选择判断：所选4张素材的No.合计值，必须能在特殊召唤候补中找到No.编号相同的怪兽。
function c20994205.gselect(g,spg)
	-- 检查特殊召唤候补中是否存在No.数值等于已选4张No.合计值的怪兽。
	return spg:IsExists(c20994205.spnofilter,1,g,g:GetSum(aux.GetXyzNumber))
end
-- 筛选No.编号等于指定数值的「No.」超量怪兽。
function c20994205.spnofilter(c,sum)
	-- 判断卡的No.编号是否等于指定值sum。
	return aux.GetXyzNumber(c)==sum
end
-- 生成附加检查函数：要求所选4张卡阶级互不相同，且No.合计不超过max（可特殊召唤的最大No.编号）。
function c20994205.gcheck(max)
	return	function(g)
				-- 检查所选素材的阶级种类数等于数量（即阶级互不相同），且No.合计不超过上限max。
				return g:GetClassCount(Card.GetRank)==#g and g:GetSum(aux.GetXyzNumber)<=max
			end
end
-- 效果发动的目标阶段：确认可以选出4张符合条件且阶级互异的「No.」素材，并设置本次特殊召唤的操作信息。
function c20994205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否存在『必须作为超量素材』的效果限制；若有则本效果不能发动。
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return false end
		-- 取得额外卡组中所有符合条件的「No.」超量怪兽作为素材候选组。
		local mg=Duel.GetMatchingGroup(c20994205.nofilter,tp,LOCATION_EXTRA,0,nil)
		-- 取得额外卡组中所有可被当作超量召唤特殊召唤的「No.」超量怪兽作为特殊召唤候选组。
		local spg=Duel.GetMatchingGroup(c20994205.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if #mg<5 or #spg==0 then return false end
		-- 取得特殊召唤候补中的最大No.编号，作为选择4张素材时No.合计的上限。
		local _,max=spg:GetMaxGroup(aux.GetXyzNumber)
		-- 设置额外的子组检查函数，以限制后续选择的4张素材阶级互异且No.合计不超过上限。
		aux.GCheckAdditional=c20994205.gcheck(max)
		local res=mg:CheckSubGroup(c20994205.gselect,4,4,spg)
		-- 清除额外子组检查函数，避免影响其他选择操作。
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：重新取得候选组并让玩家选择4张素材，再选择No.合计对应的1只No.超量怪兽，当作超量召唤特殊召唤并将素材叠放，最后附加自肃效果。
function c20994205.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认不存在『必须作为超量素材』的限制，若有则效果不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 处理时重新取得额外的No.超量素材候选组。
	local mg=Duel.GetMatchingGroup(c20994205.nofilter,tp,LOCATION_EXTRA,0,nil)
	-- 处理时重新取得可特殊召唤的No.超量怪兽候选组。
	local spg=Duel.GetMatchingGroup(c20994205.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #mg<5 or #spg==0 then return end
	-- 处理时重新取得最大No.编号作为素材合计上限。
	local _,max=spg:GetMaxGroup(aux.GetXyzNumber)
	-- 提示玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 设置额外的子组检查函数，用于素材选择时的合法性验证。
	aux.GCheckAdditional=c20994205.gcheck(max)
	local sg=mg:SelectSubGroup(tp,c20994205.gselect,false,4,4,spg)
	-- 清除额外子组检查函数，避免影响后续选择。
	aux.GCheckAdditional=nil
	if sg then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从特殊召唤候补中筛选No.编号等于已选4张No.合计值的1只怪兽作为特殊召唤对象。
		local xyz=spg:FilterSelect(tp,c20994205.spnofilter,1,1,sg,sg:GetSum(aux.GetXyzNumber)):GetFirst()
		xyz:SetMaterial(nil)
		-- 将选择的No.超量怪兽当作超量召唤从额外卡组特殊召唤。
		Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		xyz:CompleteProcedure()
		-- 将选中的4只怪兽叠放在该超量怪兽下方，作为超量素材。
		Duel.Overlay(xyz,sg)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「No.」超量怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetCondition(c20994205.splimitcon)
		e1:SetTarget(c20994205.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		xyz:RegisterEffect(e1,true)
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「No.」超量怪兽不能特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(63060238)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetAbsoluteRange(tp,1,0)
		e2:SetCondition(c20994205.splimitcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		xyz:RegisterEffect(e2,true)
	end
end
-- 自肃效果持续判定：该特殊召唤的怪兽仍在自己场上且由自己控制。
function c20994205.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 自肃筛选：要特殊召唤的怪兽若不是「No.」超量怪兽，则禁止特殊召唤。
function c20994205.splimit(e,c)
	return not c20994205.nofilter(c)
end
