--EMターントルーパー
-- 效果：
-- ①：自己战斗阶段开始时才能发动。给这张卡放置1个指示物（最多2个）。
-- ②：这张卡得到这张卡的指示物数量的以下效果。
-- ●1个：1回合1次，对方怪兽的攻击宣言时才能发动。那次攻击无效。
-- ●2个：把这张卡解放才能发动。直到发动后第2次的对方结束阶段，场上的怪兽全部除外。
function c220414.initial_effect(c)
	c:EnableCounterPermit(0x50)
	c:SetCounterLimit(0x50,2)
	-- ①：自己战斗阶段开始时才能发动。给这张卡放置1个指示物（最多2个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(220414,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c220414.ctcon)
	e1:SetTarget(c220414.cttg)
	e1:SetOperation(c220414.ctop)
	c:RegisterEffect(e1)
	-- ●1个：1回合1次，对方怪兽的攻击宣言时才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(220414,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c220414.negcon)
	e2:SetOperation(c220414.negop)
	c:RegisterEffect(e2)
	-- ●2个：把这张卡解放才能发动。直到发动后第2次的对方结束阶段，场上的怪兽全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(220414,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c220414.rmcon)
	e3:SetCost(c220414.rmcost)
	e3:SetTarget(c220414.rmtg)
	e3:SetOperation(c220414.rmop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：确认当前回合玩家是否为这张卡的控制者（tp），即自己战斗阶段开始时才能发动。
function c220414.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于这张卡的控制者tp，满足自方战斗阶段开始的条件。
	return Duel.GetTurnPlayer()==tp
end
-- 效果①的发动合法判定：检查这张卡是否还能放置1个指示物（因有最多2个的限制，若已有2个则不能发动）。
function c220414.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x50,1) end
end
-- 效果①处理：若这张卡仍与此效果关联，则给它放置1个指示物。
function c220414.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x50,1)
	end
end
-- 效果②1个指示物状态的触发条件：攻击方怪兽的控制者不是自己（即对方怪兽攻击宣言），且这张卡有1个指示物。
function c220414.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽进行攻击宣言（攻击怪兽控制者不等于tp），并且这张卡的指示物数量为1。
	return Duel.GetAttacker():GetControler()~=tp and e:GetHandler():GetCounter(0x50)==1
end
-- 攻击无效效果的处理：直接无效该次攻击。
function c220414.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击宣言的攻击。
	Duel.NegateAttack()
end
-- 效果②2个指示物状态的发动条件：这张卡的指示物数量为2。
function c220414.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x50)==2
end
-- 2个指示物效果的发动代价：先检查这张卡是否可以解放，再将其解放作为代价。
function c220414.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把这张卡解放以支付发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②2个指示物发动时的目标检查与操作信息设定：以场上所有可除外的怪兽为对象，记录将要除外它们的数量。
function c220414.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认场上存在至少1只可以被除外的怪兽（不包括已不在场上的这张卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 选取场上所有可以除外的怪兽组成一个组g。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果将除外g中的所有怪兽，数量为g的数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果②2个指示物的处理：将场上所有可除外的怪兽暂时除外，并注册一个在对方结束阶段阶段结束时将这些怪兽返回场上的效果，计数到第2次对方结束阶段时返回。
function c220414.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得场上所有可以除外的怪兽组g，用于实际除外。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果且暂时除外的方式移除g中的怪兽；若实际移除数量不为0则继续后续处理。
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local c=e:GetHandler()
		-- 取得刚刚实际被除外的怪兽组，以便标记并用于后续返回。
		local og=Duel.GetOperatedGroup()
		local fid=c:GetFieldID()
		local tc=og:GetFirst()
		while tc do
			tc:RegisterFlagEffect(220414,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2,fid)
			tc=og:GetNext()
		end
		c:SetTurnCounter(0)
		og:KeepAlive()
		-- 直到发动后第2次的对方结束阶段，场上的怪兽全部除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(c220414.retcon)
		e1:SetOperation(c220414.retop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		-- 将负责在对方结束阶段阶段结束时处理怪兽返回的持续效果注册到场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断一张卡是否带有本次除外返回的标记fid，用于筛选应返回的怪兽。
function c220414.retfilter(c,fid)
	return c:GetFlagEffectLabel(220414)==fid
end
-- 返回效果的触发条件：仅在对方结束阶段且仍有带对应标记的怪兽存在时返回。
function c220414.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前回合玩家是自己（tp），说明不是对方结束阶段，不触发返回。
	if Duel.GetTurnPlayer()==tp then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c220414.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 返回处理：每经过一次对方结束阶段计数加1，当计数达到2时，将之前除外的怪兽返回场上。
function c220414.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		local g=e:GetLabelObject()
		local sg=g:Filter(c220414.retfilter,nil,e:GetLabel())
		g:DeleteGroup()
		local tc=sg:GetFirst()
		while tc do
			-- 将暂时除外的卡返回到场上。
			Duel.ReturnToField(tc)
			tc=sg:GetNext()
		end
	end
end
