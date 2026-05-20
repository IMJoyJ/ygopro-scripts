--予見通帳
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己卡组上面把3张卡里侧表示除外。这张卡的发动后第3次的自己准备阶段，这个效果除外的3张卡加入手卡。
function c56256517.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己卡组上面把3张卡里侧表示除外。这张卡的发动后第3次的自己准备阶段，这个效果除外的3张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56256517+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56256517.target)
	e1:SetOperation(c56256517.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标过滤与处理：检查自己卡组上方3张卡是否能里侧表示除外，并设置除外操作信息。
function c56256517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的3张卡。
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)==3 end
	-- 设置操作信息：从卡组将3张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
-- 效果处理：将卡组顶端的卡里侧表示除外，并注册一个在第3个自己准备阶段将这些卡加入手卡的效果。
function c56256517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的卡片数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>3 then ct=3 end
	-- 获取自己卡组最上方的指定数量（最多3张）的卡片。
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 使接下来的操作不检测是否需要洗牌（防止除外卡组顶端卡片时自动洗牌）。
	Duel.DisableShuffleCheck()
	-- 将这些卡因效果里侧表示除外。
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	-- 如果除外的卡片中有任何一张未能成功移动到除外区，则终止后续处理。
	if g:IsExists(aux.NOT(aux.FilterBoolFunction(Card.IsLocation,LOCATION_REMOVED)),1,nil) then return end
	g:KeepAlive()
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(56256517,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=g:GetNext()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后第3次的自己准备阶段，这个效果除外的3张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabel(fid,0)
	e1:SetLabelObject(g)
	e1:SetCondition(c56256517.thcon)
	e1:SetOperation(c56256517.thop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	-- 将该延迟加入手卡的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 延迟加入手卡效果的触发条件：必须是自己的回合。
function c56256517.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：检查卡片是否带有与本次效果对应的标记（fid）。
function c56256517.thfilter(c,fid)
	return c:GetFlagEffectLabel(56256517)==fid
end
-- 延迟加入手卡效果的操作：在每个准备阶段累加计数器，在第3次准备阶段时将标记的卡加入手卡。
function c56256517.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid,ct=e:GetLabel()
	ct=ct+1
	c:SetTurnCounter(ct)
	e:SetLabel(fid,ct)
	if ct==3 then
		local g=e:GetLabelObject()
		if g:FilterCount(c56256517.thfilter,nil,fid)==3 then
			-- 将这些被除外的卡因效果加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
