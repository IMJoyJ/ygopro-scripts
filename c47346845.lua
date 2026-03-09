--電池メン－単四型
-- 效果：
-- 这张卡召唤·反转时，可以把自己的手卡·墓地存在的1只「电池人-单四型」特殊召唤。
function c47346845.initial_effect(c)
	-- 效果原文内容：这张卡召唤·反转时，可以把自己的手卡·墓地存在的1只「电池人-单四型」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47346845,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c47346845.sumtg)
	e1:SetOperation(c47346845.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组，筛选出卡号为47346845且可以被特殊召唤的卡片。
function c47346845.filter(c,e,tp)
	return c:IsCode(47346845) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，检查场上是否有空位并确认手牌或墓地是否存在符合条件的卡片。
function c47346845.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或墓地是否存在至少一张卡号为47346845且可以被特殊召唤的卡片。
		and Duel.IsExistingMatchingCard(c47346845.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1张来自手牌或墓地的卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果发动时的操作，检查是否有空位并选择要特殊召唤的卡片。
function c47346845.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有可用区域则直接返回不执行操作。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示“请选择要特殊召唤的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地中选择一张符合条件的卡片作为目标。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47346845.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
