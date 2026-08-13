--ピクシーガーディアン
-- 效果：
-- 表侧表示的这张卡做祭品。这个回合因为对方造成的送去墓地的自己的1张魔法卡回到卡组最下面。
function c22419772.initial_effect(c)
	-- 表侧表示的这张卡做祭品。这个回合因为对方造成的送去墓地的自己的1张魔法卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22419772,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c22419772.cost)
	e1:SetTarget(c22419772.target)
	e1:SetOperation(c22419772.operation)
	c:RegisterEffect(e1)
end
-- 代价处理：检查这张卡可否解放，可以则解放自身作为代价。
function c22419772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为这张卡效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地候选卡筛选：所选卡必须能够返回卡组、是魔法卡、本回合进入墓地，且导致其进入墓地的玩家是对方。
function c22419772.filter(c,tp,tid)
	return c:IsAbleToDeck() and c:IsType(TYPE_SPELL) and c:GetTurnID()==tid and c:GetReasonPlayer()==1-tp
end
-- 取对象效果的目标选择处理：从自己墓地选择1张本回合因对方原因送去墓地的魔法卡作为对象，并设置返回卡组的操作信息。
function c22419772.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判断对象卡是否为本回合进入墓地。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22419772.filter(chkc,tp,tid) end
	-- 发动合法性检查：确认自己墓地存在至少1张符合条件的魔法卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c22419772.filter,tp,LOCATION_GRAVE,0,1,nil,tp,tid) end
	-- 向操作者发送选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22419772.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp,tid)
	-- 设置操作信息，声明本次效果处理将把对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：取得对象卡，若该卡仍与本效果关联，则将其返回卡组最下面。
function c22419772.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送入持有者卡组最下面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
