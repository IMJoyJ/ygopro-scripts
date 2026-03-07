--牙竜咆哮
-- 效果：
-- ①：把自己墓地的地·水·炎·风属性怪兽各1只除外才能发动。选场上1张卡回到持有者卡组。
function c34898052.initial_effect(c)
	-- 效果原文内容：①：把自己墓地的地·水·炎·风属性怪兽各1只除外才能发动。选场上1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34898052,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c34898052.cost)
	e1:SetTarget(c34898052.target)
	e1:SetOperation(c34898052.activate)
	c:RegisterEffect(e1)
end
-- 创建一个检查函数数组，用于验证是否满足地·水·炎·风属性各1只的除外条件
c34898052.rchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND})
-- 定义过滤函数，用于筛选墓地中的地·水·炎·风属性怪兽，且为怪兽卡并可作为除外代价
function c34898052.rfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：检索满足条件的墓地怪兽组并除外
function c34898052.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c34898052.rfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroupEach(c34898052.rchecks) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c34898052.rchecks)
	-- 将选中的卡除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果处理：确认场上存在可送回卡组的卡
function c34898052.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张可送回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有可送回卡组的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果处理信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：选择场上1张卡送回卡组
function c34898052.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1张可送回卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 显示选中卡的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
