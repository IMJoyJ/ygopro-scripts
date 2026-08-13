--ライトロード・アーク ミカエル
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- ①：1回合1次，支付1000基本分，以场上1张卡为对象才能发动。那张卡除外。
-- ②：这张卡被破坏时，以这张卡以外的自己墓地的「光道」怪兽任意数量为对象才能发动。那些怪兽回到卡组，自己回复回去数量×300基本分。
-- ③：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c4779823.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的光属性怪兽1只以上（调整可以为任意调整，非调整必须是光属性怪兽）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，支付1000基本分，以场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4779823,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c4779823.rmcost)
	e1:SetTarget(c4779823.rmtg)
	e1:SetOperation(c4779823.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏时，以这张卡以外的自己墓地的「光道」怪兽任意数量为对象才能发动。那些怪兽回到卡组，自己回复回去数量×300基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4779823,1))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetTarget(c4779823.rettg)
	e2:SetOperation(c4779823.retop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4779823,2))  --"送墓"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c4779823.discon)
	e3:SetTarget(c4779823.distg)
	e3:SetOperation(c4779823.disop)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价函数：检查并支付1000基本分作为发动代价。
function c4779823.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段确认玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分，作为效果①的发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 效果①的取对象处理函数：选择场上1张可以除外的卡作为对象，并设置除外相关的操作信息。
function c4779823.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 在发动条件检查阶段，确认场上存在至少1张可以除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：本效果将把1张对象卡除外，用于后续时点及判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的发动处理函数：将选择的对象卡除外。
function c4779823.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示将该对象卡除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义效果②选择对象的筛选条件：是「光道」怪兽、是怪兽且能返回卡组。
function c4779823.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的取对象处理函数：选择自己墓地任意数量的符合条件的「光道」怪兽，并设置回卡组和回复LP的信息。
function c4779823.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4779823.filter(chkc) end
	-- 在发动条件检查阶段，确认自己墓地存在至少1张符合条件的「光道」怪兽（且不是本卡自身）。
	if chk==0 then return Duel.IsExistingTarget(c4779823.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1~99张符合条件的「光道」怪兽（排除自身）作为效果对象。
	local g=Duel.SelectTarget(tp,c4779823.filter,tp,LOCATION_GRAVE,0,1,99,e:GetHandler())
	-- 设置操作信息：将选择的对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：本效果将回复自己数值为对象数量×300的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*300)
end
-- 效果②的发动处理函数：将对象卡返回卡组，并按返回数量回复LP。
function c4779823.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时仍与本效果相关的对象卡组，排除已无效或离场导致不相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡返回持有者卡组并洗牌，返回实际返回卡组的数量。
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		-- 根据实际返回卡组的数量回复自己基本分，每张×300。
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end
-- 效果③的发动条件函数：仅在自己回合的结束阶段满足。
function c4779823.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（控制者），以保证是自己结束阶段。
	return tp==Duel.GetTurnPlayer()
end
-- 效果③的发动设定函数：必发效果，设置将卡组上方3张卡送去墓地的信息。
function c4779823.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从自己卡组上方把3张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果③的发动处理函数：从自己卡组上方把3张卡送去墓地。
function c4779823.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组上方3张卡送去墓地。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
