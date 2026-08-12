--天界王 シナト
-- 效果：
-- 用「奇迹之方舟」特殊召唤。特殊召唤时，必须以场上或手卡中合计8颗星以上的怪兽作为祭品。这张卡战斗破坏对方守备表示的怪兽并将其送去墓地时，对方受到数值与被破坏怪兽的原本攻击力相同的伤害。
function c86327225.initial_effect(c)
	-- 将「奇迹之方舟」卡片密码（60365591）添加到该卡的关系代码列表中，以在规则层面表明该卡上记载了其卡名。
	aux.AddCodeList(c,60365591)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方守备表示的怪兽并将其送去墓地时，对方受到数值与被破坏怪兽的原本攻击力相同的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86327225,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c86327225.damcon)
	e1:SetTarget(c86327225.damtg)
	e1:SetOperation(c86327225.damop)
	c:RegisterEffect(e1)
end
-- 效果的发动条件：此卡参与了战斗，战斗破坏了对方怪兽并送去墓地，且被破坏的怪兽在战斗时是守备表示。
function c86327225.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
		and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 效果的发动准备：获取与此卡进行战斗并被破坏的对方怪兽原本攻击力数值，并设置伤害效果的操作参数及信息。
function c86327225.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 设置伤害对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为被破坏怪兽的原本攻击力。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：给对方玩家造成原本攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果的处理：从当前连锁信息中获取伤害的目标玩家和伤害值，对其造成效果伤害。
function c86327225.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取设定的伤害目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与指定玩家相应的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
