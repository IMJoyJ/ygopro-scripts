--ライトロード・アーク ミカエル
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- ①：1回合1次，支付1000基本分，以场上1张卡为对象才能发动。那张卡除外。
-- ②：这张卡被破坏时，以这张卡以外的自己墓地的「光道」怪兽任意数量为对象才能发动。那些怪兽回到卡组，自己回复回去数量×300基本分。
-- ③：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c4779823.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上光属性调整以外的怪兽作为素材
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
-- 检查玩家是否能支付1000基本分
function c4779823.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置效果目标为场上1张可除外的卡
function c4779823.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查场上是否存在1张可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张可除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定将1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果，将目标卡除外
function c4779823.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义过滤函数，筛选光道怪兽且可送回卡组的卡片
function c4779823.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果目标为墓地里任意数量的光道怪兽
function c4779823.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4779823.filter(chkc) end
	-- 检查玩家墓地中是否存在至少1张符合条件的光道怪兽
	if chk==0 then return Duel.IsExistingTarget(c4779823.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地里任意数量的光道怪兽作为对象
	local g=Duel.SelectTarget(tp,c4779823.filter,tp,LOCATION_GRAVE,0,1,99,e:GetHandler())
	-- 设置效果操作信息，指定将若干张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果操作信息，指定回复相应数量×300基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*300)
end
-- 处理效果，将目标卡送回卡组并回复基本分
function c4779823.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡组，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡送回卡组
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		-- 根据送回卡组的数量回复基本分
		Duel.Recover(tp,ct*300,REASON_EFFECT)
	end
end
-- 设置效果发动条件，仅在自己的结束阶段发动
function c4779823.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果目标为从自己卡组上面把3张卡送去墓地
function c4779823.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果操作信息，指定将3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 处理效果，从自己卡组上面把3张卡送去墓地
function c4779823.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组上面把3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
