--ニードルバンカー
-- 效果：
-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500点的伤害。
function c98162242.initial_effect(c)
	-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500点的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98162242,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c98162242.damcon)
	e1:SetTarget(c98162242.damtg)
	e1:SetOperation(c98162242.damop)
	c:RegisterEffect(e1)
end
-- 确认发动条件：自身与战斗关联，且战斗破坏的怪兽被送去墓地。
function c98162242.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 确认效果发动：计算被破坏怪兽等级×500的伤害值，并设置目标玩家与伤害参数。
function c98162242.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetLevel()*500
	-- 设置当前连锁的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的伤害数值参数。
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家对应数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行效果处理：获取目标玩家和伤害数值，并给与对方效果伤害。
function c98162242.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
