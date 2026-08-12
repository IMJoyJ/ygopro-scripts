--BF－二の太刀のエテジア
-- 效果：
-- 自己场上存在的名字带有「黑羽」的怪兽进行和对方怪兽的战斗的伤害步骤结束时那只对方怪兽在场上存在的场合，把这张卡从手卡送去墓地才能发动。给与对方基本分1000分伤害。
function c78564023.initial_effect(c)
	-- 自己场上存在的名字带有「黑羽」的怪兽进行和对方怪兽的战斗的伤害步骤结束时那只对方怪兽在场上存在的场合，把这张卡从手卡送去墓地才能发动。给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78564023,0))  --"给与对方1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c78564023.condition)
	e1:SetCost(c78564023.cost)
	e1:SetTarget(c78564023.target)
	e1:SetOperation(c78564023.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：自己控制的「黑羽」怪兽与对方怪兽进行战斗，且在伤害步骤结束时对方怪兽仍在场上
function c78564023.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsSetCard(0x33) and a:IsRelateToBattle() and d and d:IsRelateToBattle()
end
-- 检查并执行发动代价：将手牌中的这张卡送去墓地
function c78564023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果的目标玩家为对方，目标数值为1000，并向系统申报伤害操作信息
function c78564023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的目标参数（伤害数值）设置为1000
	Duel.SetTargetParam(1000)
	-- 向系统申报当前连锁的操作信息：对对方玩家造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行效果：获取目标玩家和伤害数值，给与对方1000点伤害
function c78564023.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
