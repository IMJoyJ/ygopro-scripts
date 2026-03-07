--女豹の傭兵
-- 效果：
-- 表侧表示的这张卡做祭品。1只这个回合被战斗破坏送去墓地的自己的怪兽回到卡组的最上面。
function c38480590.initial_effect(c)
	-- 表侧表示的这张卡做祭品。1只这个回合被战斗破坏送去墓地的自己的怪兽回到卡组的最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c38480590.cost)
	e1:SetTarget(c38480590.target)
	e1:SetOperation(c38480590.operation)
	c:RegisterEffect(e1)
end
-- 支付效果代价：解放这张卡
function c38480590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检查目标是否为怪兽卡且是本回合被战斗破坏送入墓地的自己的怪兽且可以送回卡组
function c38480590.filter(c,tid)
	return c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsAbleToDeck()
end
-- 选择效果对象：从自己墓地选择1只符合条件的怪兽
function c38480590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判断怪兽是否为本回合被战斗破坏
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38480590.filter(chkc,tid) end
	-- 确认是否满足选择对象的条件：墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38480590.filter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c38480590.filter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置效果处理信息，指定将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将选中的怪兽送回卡组最上面
function c38480590.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
