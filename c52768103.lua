--KA－2 デス・シザース
-- 效果：
-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500点的伤害。
function c52768103.initial_effect(c)
	-- 这张卡战斗破坏怪兽并将其送去墓地时，对对方基本分造成数值等同于被破坏怪兽等级×500 点的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52768103,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c52768103.damcon)
	e1:SetTarget(c52768103.damtg)
	e1:SetOperation(c52768103.damop)
	c:RegisterEffect(e1)
end
-- 检查战斗破坏的怪兽是否送去墓地且为战斗破坏的怪兽卡
function c52768103.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 计算伤害数值并设置连锁对象玩家及伤害参数
function c52768103.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetLevel()*500
	-- 设置伤害对象为玩家对手
	Duel.SetTargetPlayer(1-tp)
	-- 设置造成的伤害数值
	Duel.SetTargetParam(dam)
	-- 注册效果处理时将造成指定数值的伤害给对手
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 获取连锁参数并执行伤害处理
function c52768103.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
