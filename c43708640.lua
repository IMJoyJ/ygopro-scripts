--ミノケンサテュロス
-- 效果：
-- 这张卡不能特殊召唤。可以把这张卡解放，从自己卡组把2只兽战士族·4星的通常怪兽特殊召唤。
function c43708640.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 可以把这张卡解放，从自己卡组把2只兽战士族·4星的通常怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43708640,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43708640.spcost)
	e2:SetTarget(c43708640.sptg)
	e2:SetOperation(c43708640.spop)
	c:RegisterEffect(e2)
end
-- 检查是否可以支付将此卡解放作为cost的条件。
function c43708640.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为cost。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选满足条件的通常怪兽（4星，兽战士族，可特殊召唤）。
function c43708640.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(4) and c:IsRace(RACE_BEASTWARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：未被青眼精灵龙效果影响、场上存在空位、卡组存在至少2只符合条件的怪兽。
function c43708640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断场上是否有足够的怪兽区域来特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在至少2只符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c43708640.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁处理信息，表示将要特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：若满足条件则从卡组选择2只符合条件的怪兽特殊召唤。
function c43708640.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否至少有2个空怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合条件的怪兽组成Group。
	local g=Duel.GetMatchingGroup(c43708640.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选定的怪兽特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
