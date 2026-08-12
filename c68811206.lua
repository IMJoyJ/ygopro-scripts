--
-- 效果：
-- 这张卡不能特殊召唤。当这张卡战斗破坏怪兽并将它送去墓地时，给与对方等于被破坏怪兽的攻击力数值的伤害。
function c68811206.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 当这张卡战斗破坏怪兽并将它送去墓地时，给与对方等于被破坏怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68811206,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c68811206.damcon)
	e2:SetTarget(c68811206.damtg)
	e2:SetOperation(c68811206.damop)
	c:RegisterEffect(e2)
end
-- 判断自身是否与战斗相关，且被战斗破坏的怪兽已送去墓地且是怪兽卡
function c68811206.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果发动的目标确认，获取被破坏怪兽的攻击力，并设置伤害的对象玩家、伤害数值以及操作信息
function c68811206.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为被破坏怪兽的攻击力数值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理，获取设定的目标玩家和伤害数值，并执行给与伤害的操作
function c68811206.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
