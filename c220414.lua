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
	-- ②：这张卡得到这张卡的指示物数量的以下效果。●1个：1回合1次，对方怪兽的攻击宣言时才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(220414,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c220414.negcon)
	e2:SetOperation(c220414.negop)
	c:RegisterEffect(e2)
	-- ②：这张卡得到这张卡的指示物数量的以下效果。●2个：把这张卡解放才能发动。直到发动后第2次的对方结束阶段，场上的怪兽全部除外。
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
-- 判断是否为自己的回合
function c220414.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 判断是否可以放置指示物
function c220414.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x50,1) end
end
-- 放置1个指示物
function c220414.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x50,1)
	end
end
-- 判断是否为对方攻击且自身有1个指示物
function c220414.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方攻击且自身有1个指示物
	return Duel.GetAttacker():GetControler()~=tp and e:GetHandler():GetCounter(0x50)==1
end
-- 无效攻击
function c220414.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效攻击
	Duel.NegateAttack()
end
-- 判断是否拥有2个指示物
function c220414.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x50)==2
end
-- 支付解放费用
function c220414.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 支付解放费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置除外效果的操作信息
function c220414.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上所有可除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行除外效果并设置返回效果
function c220414.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 执行除外操作
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local c=e:GetHandler()
		-- 获取实际被除外的怪兽组
		local og=Duel.GetOperatedGroup()
		local fid=c:GetFieldID()
		local tc=og:GetFirst()
		while tc do
			tc:RegisterFlagEffect(220414,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2,fid)
			tc=og:GetNext()
		end
		c:SetTurnCounter(0)
		og:KeepAlive()
		-- 注册持续效果以在指定回合结束后将怪兽返回场上
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
		-- 注册效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：判断怪兽是否具有指定的标志ID
function c220414.retfilter(c,fid)
	return c:GetFlagEffectLabel(220414)==fid
end
-- 判断是否满足返回场上的条件
function c220414.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	if Duel.GetTurnPlayer()==tp then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c220414.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 处理返回场上的操作
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
			-- 将怪兽返回场上
			Duel.ReturnToField(tc)
			tc=sg:GetNext()
		end
	end
end
