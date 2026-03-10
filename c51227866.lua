--閃刀機－シャークキャノン
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。自己墓地有魔法卡3张以上存在的场合，可以不除外而把那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽不能攻击。
function c51227866.initial_effect(c)
	-- 效果作用
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c51227866.condition)
	e1:SetTarget(c51227866.target)
	e1:SetOperation(c51227866.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查自己场上是否有怪兽存在
function c51227866.cfilter(c)
	return c:GetSequence()<5
end
-- 效果条件：自己的主要怪兽区域没有怪兽存在的场合
function c51227866.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己的主要怪兽区域没有怪兽存在的场合
	return not Duel.IsExistingMatchingCard(c51227866.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查对方墓地的怪兽是否可以除外或特殊召唤
function c51227866.filter(c,e,tp,spchk)
	return c:IsType(TYPE_MONSTER) and (c:IsAbleToRemove() or (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 选择目标：以对方墓地1只怪兽为对象
function c51227866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断自己场上是否有空位
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否有3张以上魔法卡
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c51227866.filter(chkc,e,tp,spchk) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c51227866.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,spchk) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c51227866.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,spchk)
end
-- 效果处理：根据条件决定是除外还是特殊召唤
function c51227866.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 检查是否被王家长眠之谷保护
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 判断自己墓地是否有3张以上魔法卡
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			-- 判断自己场上是否有空位且目标怪兽可以特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否选择特殊召唤
			and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(51227866,0))) then  --"是否特殊召唤？"
			-- 将目标怪兽特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 效果原文内容：这个效果特殊召唤的怪兽不能攻击
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		else
			-- 将目标怪兽除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
