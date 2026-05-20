--風霊術－「雅」
-- 效果：
-- ①：把自己场上1只风属性怪兽解放，以对方场上1张卡为对象才能发动。那张对方的卡回到持有者卡组最下面。
function c79333300.initial_effect(c)
	-- ①：把自己场上1只风属性怪兽解放，以对方场上1张卡为对象才能发动。那张对方的卡回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c79333300.cost)
	e1:SetTarget(c79333300.target)
	e1:SetOperation(c79333300.activate)
	c:RegisterEffect(e1)
end
-- 处理发动代价（Cost）：解放自己场上1只风属性怪兽
function c79333300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的风属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_WIND) end
	-- 玩家选择自己场上1只风属性怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WIND)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 处理发动效果时的对象选择与操作信息设置
function c79333300.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在可以回到卡组的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 处理效果：使作为对象的卡回到持有者卡组最下面
function c79333300.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡送回持有者卡组最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
