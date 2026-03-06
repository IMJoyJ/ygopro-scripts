--生者の書－禁断の呪術－
-- 效果：
-- ①：以自己墓地1只不死族怪兽和对方墓地1只怪兽为对象才能发动。那只自己的不死族怪兽特殊召唤。那只对方怪兽除外。
function c2204140.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只不死族怪兽和对方墓地1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c2204140.target)
	e1:SetOperation(c2204140.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的不死族怪兽（可特殊召唤）
function c2204140.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索满足条件的怪兽（可除外）
function c2204140.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果作用：判断是否满足发动条件
function c2204140.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：判断自己场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断对方墓地是否存在可除外的怪兽
		and Duel.IsExistingTarget(c2204140.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
		-- 效果作用：判断自己墓地是否存在可特殊召唤的不死族怪兽
		and Duel.IsExistingTarget(c2204140.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的不死族怪兽作为特殊召唤对象
	local g1=Duel.SelectTarget(tp,c2204140.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的怪兽作为除外对象
	local g2=Duel.SelectTarget(tp,c2204140.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 效果作用：设置除外操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,1-tp,LOCATION_GRAVE)
end
-- 效果原文内容：那只自己的不死族怪兽特殊召唤。那只对方怪兽除外。
function c2204140.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取特殊召唤的目标对象
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	-- 效果作用：获取除外的目标对象
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if tg1:GetFirst():IsRelateToEffect(e) and tg1:GetFirst():IsRace(RACE_ZOMBIE) then
		-- 效果作用：将目标不死族怪兽特殊召唤
		Duel.SpecialSummon(tg1,0,tp,tp,false,false,POS_FACEUP)
	end
	if tg2:GetFirst():IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽除外
		Duel.Remove(tg2,POS_FACEUP,REASON_EFFECT)
	end
end
