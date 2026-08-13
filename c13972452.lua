--マジェスペクター・ストーム
-- 效果：
-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
function c13972452.initial_effect(c)
	-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13972452.cost)
	e1:SetTarget(c13972452.target)
	e1:SetOperation(c13972452.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：判断怪兽是否为魔法师族且风属性，用于选择解放的怪兽。
function c13972452.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 代价函数：选择并解放自己场上1只魔法师族·风属性怪兽作为发动代价。
function c13972452.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查（chk==0时）：确认自己场上是否存在至少1只满足魔法师族·风属性条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13972452.cfilter,1,nil) end
	-- 从自己场上选择1只满足条件的可解放怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,c13972452.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为效果发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 目标处理函数：以对方场上1只怪兽为对象，并设置回卡组的效果信息。
function c13972452.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 目标检查（chk==0时）：确认对方怪兽区是否存在至少1只可返回卡组的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方怪兽区选择1只可以返回卡组的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果将对象怪兽返回卡组（CATEGORY_TODECK），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数：将对象怪兽返回持有者卡组。
function c13972452.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回持有者卡组并洗牌（REASON_EFFECT，SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
