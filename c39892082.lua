--バルーン・リザード
-- 效果：
-- 每到自己的准备阶段时，在这张卡上放置1个指示物。破坏这张卡的卡的控制者受到这张卡上放置的指示物数量×400点的伤害。
function c39892082.initial_effect(c)
	c:EnableCounterPermit(0x29)
	-- 诱发必发效果，于准备阶段时发动，放置1个指示物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39892082,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39892082.addccon)
	e1:SetTarget(c39892082.addct)
	e1:SetOperation(c39892082.addc)
	c:RegisterEffect(e1)
	-- 当此卡离开场时，记录当前指示物数量
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c39892082.regop)
	c:RegisterEffect(e0)
	-- 此卡被破坏时，破坏者受到指示物数量×400点的伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39892082,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c39892082.damcon)
	e2:SetTarget(c39892082.damtg)
	e2:SetOperation(c39892082.damop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的准备阶段
function c39892082.addccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 设置连锁操作信息，准备放置1个指示物
function c39892082.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，准备放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x29)
end
-- 将指示物放置到自己身上
function c39892082.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x29,1)
	end
end
-- 记录当前指示物数量
function c39892082.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x29)
	e:SetLabel(ct)
end
-- 判断是否有指示物存在
function c39892082.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
-- 设置连锁操作信息，准备对对手造成伤害
function c39892082.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，准备对对手造成伤害
	Duel.SetTargetPlayer(rp)
	-- 设置连锁操作信息，准备对对手造成伤害
	Duel.SetTargetParam(e:GetLabel()*400)
	-- 设置连锁操作信息，准备对对手造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,e:GetLabel()*400)
end
-- 执行伤害效果，对指定玩家造成伤害
function c39892082.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
