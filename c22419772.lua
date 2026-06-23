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
-- 将自身解放作为cost
function c22419772.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的魔法卡
function c22419772.filter(c,tp,tid)
	return c:IsAbleToDeck() and c:IsType(TYPE_SPELL) and c:GetTurnID()==tid and c:GetReasonPlayer()==1-tp
end
-- 选择符合条件的魔法卡作为效果对象
function c22419772.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22419772.filter(chkc,tp,tid) end
	-- 判断是否有符合条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c22419772.filter,tp,LOCATION_GRAVE,0,1,nil,tp,tid) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标魔法卡
	local g=Duel.SelectTarget(tp,c22419772.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp,tid)
	-- 设置效果处理信息为将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 将选中的魔法卡送回卡组底端
function c22419772.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
