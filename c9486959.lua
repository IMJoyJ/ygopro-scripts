--神隠し鬼火丸
-- 效果：
-- 2星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到对方结束阶段除外。
-- ②：持有超量素材的这张卡被对方破坏的场合，以最多有这张卡持有的超量素材数量的自己·对方的除外状态的怪兽为对象才能发动。那些怪兽回到卡组。
function c9486959.initial_effect(c)
	-- 添加XYZ召唤手续：2星怪兽2只以上
	aux.AddXyzProcedure(c,nil,2,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽直到对方结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,9486959)
	e1:SetCost(c9486959.rmcost)
	e1:SetTarget(c9486959.rmtg)
	e1:SetOperation(c9486959.rmop)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡被对方破坏的场合，以最多有这张卡持有的超量素材数量的自己·对方的除外状态的怪兽为对象才能发动。那些怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,9486960)
	e2:SetCondition(c9486959.tdcon)
	e2:SetTarget(c9486959.tdtg)
	e2:SetOperation(c9486959.tdop)
	c:RegisterEffect(e2)
end
-- ①号效果的代价：取除这张卡的1个超量素材
function c9486959.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①号效果的目标选择：以对方场上1只怪兽为对象
function c9486959.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在发动准备阶段，确认对方场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①号效果的处理：将对象怪兽暂时除外，并注册在对方结束阶段返回场上的效果
function c9486959.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其暂时除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(9486959,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：那只怪兽直到对方结束阶段除外。②：持有超量素材的这张卡被对方破坏的场合，以最多有这张卡持有的超量素材数量的自己·对方的除外状态的怪兽为对象才能发动。那些怪兽回到卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c9486959.retcon)
		e1:SetOperation(c9486959.retop)
		-- 注册在对方回合结束时触发的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回场上效果的触发条件：对象怪兽带有特定标记，且当前是对方回合的结束阶段
function c9486959.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对象怪兽是否带有特定标记，且当前回合玩家是否为对方
	return e:GetLabelObject():GetFlagEffect(9486959)~=0 and Duel.GetTurnPlayer()==1-tp
end
-- 返回场上效果的处理：将暂时除外的怪兽返回场上
function c9486959.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的对象怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- ②号效果的发动条件：这张卡在自己场上被对方破坏
function c9486959.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②号效果的目标过滤：自己或对方除外状态的表侧表示怪兽
function c9486959.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToDeck()
end
-- ②号效果的目标选择：以最多有这张卡持有的超量素材数量的除外状态的怪兽为对象
function c9486959.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c9486959.tdfilter(chkc) end
	local ct=e:GetHandler():GetPreviousOverlayCountOnField()
	-- 在发动准备阶段，确认这张卡离场前是否持有超量素材，且除外状态是否存在符合条件的怪兽
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c9486959.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择最多等同于这张卡离场前超量素材数量的除外状态的怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c9486959.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,ct,nil)
	-- 设置效果处理信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- ②号效果的处理：将作为对象的怪兽回到卡组
function c9486959.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此效果的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍适用的对象怪兽送回卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
