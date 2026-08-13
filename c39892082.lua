--バルーン・リザード
-- 效果：
-- 每到自己的准备阶段时，在这张卡上放置1个指示物。破坏这张卡的卡的控制者受到这张卡上放置的指示物数量×400点的伤害。
function c39892082.initial_effect(c)
	c:EnableCounterPermit(0x29)
	-- 每到自己的准备阶段时，在这张卡上放置1个指示物。
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
	-- 破坏这张卡的卡的控制者受到这张卡上放置的指示物数量×400点的伤害。此行是辅助效果：在离场前记录指示物数量，为之后伤害结算做准备。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c39892082.regop)
	c:RegisterEffect(e0)
	-- 破坏这张卡的卡的控制者受到这张卡上放置的指示物数量×400点的伤害。
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
-- 此条件函数判断当前回合玩家是否为这张卡的控制者，确保只在“自己的准备阶段”触发放置指示物的效果。
function c39892082.addccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于效果发动方tp，即只有自己的准备阶段才满足条件。
	return Duel.GetTurnPlayer()==tp
end
-- 此目标函数在效果发动时可用性判断中直接返回true（必发效果无需发动条件），并设置操作信息为放置1个指示物。
function c39892082.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：效果类别为指示物（CATEGORY_COUNTER），处理时将放置1个0x29类型的指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x29)
end
-- 效果处理时，若这张卡仍与效果相关（未被无效或离场），则给这张卡放置1个0x29指示物。
function c39892082.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x29,1)
	end
end
-- 离场前触发：记录这张卡当前持有的0x29指示物数量，并存入该效果的Label中，供破坏后伤害效果使用。
function c39892082.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x29)
	e:SetLabel(ct)
end
-- 伤害触发条件：从LabelObject（即e0）中取得离场前记录的指示物数量，存入自身Label；若数量大于0则允许发动伤害效果。
function c39892082.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
-- 伤害效果的目标处理：设定对象玩家为破坏这张卡的卡的控制者rp，伤害数值为指示物数量×400，并设置操作信息。
function c39892082.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为破坏这张卡的卡的控制者rp。
	Duel.SetTargetPlayer(rp)
	-- 将当前连锁的目标参数设置为指示物数量×400，作为后续伤害数值。
	Duel.SetTargetParam(e:GetLabel()*400)
	-- 设置连锁操作信息：效果类别为伤害，目标玩家为rp，预计造成指示物数量×400点的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,e:GetLabel()*400)
end
-- 伤害效果处理的执行部分：取出连锁信息中的目标玩家和伤害数值，实际给予伤害。
function c39892082.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中一次性取得预设的对象玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以“效果”为原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
