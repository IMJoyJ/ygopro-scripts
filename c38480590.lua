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
-- 发动代价处理：在代价确认阶段（chk==0）检查这张卡能否被解放；若可以，则在发动时解放这张卡作为代价。
function c38480590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放代价（REASON_COST）将这张卡自身解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选条件：必须是怪兽，且是当前回合（取得该卡被送入墓地的回合号）被战斗破坏送去墓地，并且可以送回卡组的卡。
function c38480590.filter(c,tid)
	return c:IsType(TYPE_MONSTER) and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsAbleToDeck()
end
-- 发动目标选择处理：记录当前回合数；若是取消/再选择则验证对象是否合法；若满足发动条件则选择1张墓地中符合条件的自己的怪兽为对象，并设置回卡组的操作信息。
function c38480590.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于筛选“这个回合被战斗破坏送去墓地”的怪兽。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38480590.filter(chkc,tid) end
	-- 检查自己墓地是否存在至少1只满足条件的怪兽，作为效果发动的前提。
	if chk==0 then return Duel.IsExistingTarget(c38480590.filter,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地的符合条件的怪兽中选择1只作为效果对象（并自动与当前连锁建立对象联系）。
	local g=Duel.SelectTarget(tp,c38480590.filter,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置本次连锁的操作信息：处理为回卡组（CATEGORY_TODECK），对象为所选的g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：取得对象，若对象仍与效果关联，则将其送回持有者卡组最顶端。
function c38480590.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片以效果原因（REASON_EFFECT）送回其持有者卡组最顶端（SEQ_DECKTOP）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
