--ファイヤー・トルーパー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，可以把这张卡送去墓地，给与对方基本分1000分伤害。
function c53927679.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，可以把这张卡送去墓地，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53927679,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCost(c53927679.cost)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53927679.tg)
	e1:SetOperation(c53927679.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 支付效果代价时，检查是否可以将此卡送入墓地作为代价
function c53927679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为支付代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设定效果目标时，设置伤害对象为对方玩家并设定伤害值为1000
function c53927679.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁处理的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁处理的目标参数设置为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为伤害效果，目标为对方玩家，伤害值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理时，获取连锁的目标玩家和参数并造成相应伤害
function c53927679.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
