--ナンバーズ・エヴァイユ
-- 效果：
-- ①：从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。从额外卡组选4只「No.」超量怪兽（相同阶级最多1只）。「No.」数值和那4只的合计相同的1只「No.」超量怪兽当作超量召唤从额外卡组特殊召唤，把选的怪兽全部作为那只怪兽的超量素材。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「No.」超量怪兽不能特殊召唤。
function c20994205.initial_effect(c)
	-- 创建效果，设置为发动时点，发动后可自由连锁，条件为己方场上无从额外卡组特殊召唤的怪兽且对方场上存在从额外卡组特殊召唤的怪兽，目标为选择4只No.超量怪兽并特殊召唤1只No.超量怪兽，操作为将选中的怪兽作为超量素材叠放于特殊召唤的怪兽上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20994205.condition)
	e1:SetTarget(c20994205.target)
	e1:SetOperation(c20994205.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断卡片是否为从额外卡组召唤的怪兽。
function c20994205.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动条件，判断己方场上没有从额外卡组特殊召唤的怪兽，且对方场上存在从额外卡组特殊召唤的怪兽。
function c20994205.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否存在从额外卡组特殊召唤的怪兽。
	return not Duel.IsExistingMatchingCard(c20994205.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在从额外卡组特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c20994205.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤函数，判断卡片是否为No.超量怪兽。
function c20994205.nofilter(c)
	-- 判断卡片是否为超量怪兽、属于No.系列且具有No.编号。
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and aux.GetXyzNumber(c)
end
-- 过滤函数，判断卡片是否可以被特殊召唤为超量怪兽。
function c20994205.spfilter(c,e,tp)
	return c20994205.nofilter(c)
		-- 判断卡片是否可以被特殊召唤为超量怪兽且场上存在足够的召唤位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 子函数，用于判断选中的4只怪兽是否能组成一个No.编号等于其总和的超量怪兽。
function c20994205.gselect(g,spg)
	-- 判断选中的怪兽组中是否存在No.编号等于其总和的超量怪兽。
	return spg:IsExists(c20994205.spnofilter,1,g,g:GetSum(aux.GetXyzNumber))
end
-- 子函数，用于判断单个怪兽的No.编号是否等于指定值。
function c20994205.spnofilter(c,sum)
	-- 判断卡片的No.编号是否等于指定值。
	return aux.GetXyzNumber(c)==sum
end
-- 子函数，用于判断选中的怪兽组是否满足阶级唯一且总和不超过最大值的条件。
function c20994205.gcheck(max)
	return	function(g)
				-- 判断选中的怪兽组是否满足阶级唯一且总和不超过最大值的条件。
				return g:GetClassCount(Card.GetRank)==#g and g:GetSum(aux.GetXyzNumber)<=max
			end
end
-- 效果目标函数，检查是否满足发动条件，包括必须作为超量素材的卡、额外卡组中的No.超量怪兽数量、特殊召唤的No.超量怪兽数量及组合条件。
function c20994205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否满足作为超量素材的条件。
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return false end
		-- 获取额外卡组中所有No.超量怪兽的集合。
		local mg=Duel.GetMatchingGroup(c20994205.nofilter,tp,LOCATION_EXTRA,0,nil)
		-- 获取额外卡组中所有可特殊召唤的No.超量怪兽的集合。
		local spg=Duel.GetMatchingGroup(c20994205.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if #mg<5 or #spg==0 then return false end
		-- 获取可特殊召唤的No.超量怪兽中的最大No.编号。
		local _,max=spg:GetMaxGroup(aux.GetXyzNumber)
		-- 设置额外检查条件为gcheck函数。
		aux.GCheckAdditional=c20994205.gcheck(max)
		local res=mg:CheckSubGroup(c20994205.gselect,4,4,spg)
		-- 清除额外检查条件。
		aux.GCheckAdditional=nil
		return res
	end
	-- 设置操作信息，表示将特殊召唤1只来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动函数，执行特殊召唤操作，包括选择4只怪兽作为素材、选择1只No.超量怪兽进行特殊召唤、将素材叠放于特殊召唤的怪兽上并设置限制效果。
function c20994205.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足作为超量素材的条件。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 获取额外卡组中所有No.超量怪兽的集合。
	local mg=Duel.GetMatchingGroup(c20994205.nofilter,tp,LOCATION_EXTRA,0,nil)
	-- 获取额外卡组中所有可特殊召唤的No.超量怪兽的集合。
	local spg=Duel.GetMatchingGroup(c20994205.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #mg<5 or #spg==0 then return end
	-- 获取可特殊召唤的No.超量怪兽中的最大No.编号。
	local _,max=spg:GetMaxGroup(aux.GetXyzNumber)
	-- 提示玩家选择作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 设置额外检查条件为gcheck函数。
	aux.GCheckAdditional=c20994205.gcheck(max)
	local sg=mg:SelectSubGroup(tp,c20994205.gselect,false,4,4,spg)
	-- 清除额外检查条件。
	aux.GCheckAdditional=nil
	if sg then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从可特殊召唤的怪兽中选择No.编号等于选中怪兽总和的怪兽。
		local xyz=spg:FilterSelect(tp,c20994205.spnofilter,1,1,sg,sg:GetSum(aux.GetXyzNumber)):GetFirst()
		xyz:SetMaterial(nil)
		-- 将选中的怪兽特殊召唤为超量怪兽。
		Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		xyz:CompleteProcedure()
		-- 将选中的怪兽叠放于特殊召唤的怪兽上。
		Duel.Overlay(xyz,sg)
		-- 创建效果，禁止己方非No.超量怪兽特殊召唤。
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
		-- 创建效果，禁止己方非No.超量怪兽特殊召唤（重复效果）。
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
-- 限制效果的条件函数，判断效果持有者是否为效果发动者。
function c20994205.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 限制效果的目标函数，禁止非No.超量怪兽特殊召唤。
function c20994205.splimit(e,c)
	return not c20994205.nofilter(c)
end
