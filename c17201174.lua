--ハンマー・シャーク
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的等级下降1星，从手卡把1只水属性·3星以下的怪兽特殊召唤。
function c17201174.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时才能发动。这张卡的等级下降1星，从手卡把1只水属性·3星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17201174,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c17201174.sptg)
	e1:SetOperation(c17201174.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的水属性且等级为3星以下的手卡怪兽
function c17201174.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：自身等级至少为2星、场上存在空位、手卡存在符合条件的怪兽
function c17201174.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自身等级是否至少为2星且场上存在空位
	if chk==0 then return e:GetHandler():IsLevelAbove(2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c17201174.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：使自身等级下降1星并选择手卡符合条件的怪兽进行特殊召唤
function c17201174.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 效果原文内容：这张卡的等级下降1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 判断场上是否还有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c17201174.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
