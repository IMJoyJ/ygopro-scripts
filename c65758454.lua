--ガンバランサー
-- 效果：
-- 这张卡召唤成功时，可以从自己的手卡·墓地选1只「加把劲枪兵」表侧守备表示特殊召唤。
function c65758454.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己的手卡·墓地选1只「加把劲枪兵」表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65758454,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c65758454.sptg)
	e1:SetOperation(c65758454.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为「加把劲枪兵」且可以被特殊召唤（表侧守备表示）
function c65758454.filter(c,e,tp)
	return c:IsCode(65758454) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查与准备函数
function c65758454.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只可以特殊召唤的「加把劲枪兵」
		and Duel.IsExistingMatchingCard(c65758454.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理的执行函数
function c65758454.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或墓地选择1只满足过滤条件且不受「王家长眠之谷」影响的「加把劲枪兵」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c65758454.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
