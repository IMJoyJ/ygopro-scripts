--六武衆の理
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「六武众」的怪兽送去墓地才能发动。选择自己或者对方的墓地1只名字带有「六武众」的怪兽在自己场上特殊召唤。
function c27178262.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的1只名字带有「六武众」的怪兽送去墓地才能发动。选择自己或者对方的墓地1只名字带有「六武众」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27178262.cost)
	e1:SetTarget(c27178262.target)
	e1:SetOperation(c27178262.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示、六武众卡族、可作为费用送去墓地、满足位置限制条件
function c27178262.costfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 效果作用：支付费用，将满足条件的1只场上表侧表示的六武众怪兽送去墓地
function c27178262.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取玩家当前场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：判断是否满足支付费用的条件
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c27178262.costfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的1只场上表侧表示的六武众怪兽
	local g=Duel.SelectMatchingCard(tp,c27178262.costfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 效果作用：将选择的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索满足条件的卡片组：六武众卡族、可特殊召唤
function c27178262.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：选择目标，从自己或对方墓地选择1只六武众怪兽作为特殊召唤对象
function c27178262.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c27178262.filter(chkc,e,tp) end
	-- 效果作用：判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c27178262.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的1只墓地六武众怪兽
	local g=Duel.SelectTarget(tp,c27178262.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理效果，将选择的墓地怪兽特殊召唤到场上
function c27178262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
