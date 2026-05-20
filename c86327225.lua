--天界王 シナト
-- 效果：
-- 用「奇迹之方舟」特殊召唤。特殊召唤时，必须以场上或手卡中合计8颗星以上的怪兽作为祭品。这张卡战斗破坏对方守备表示的怪兽并将其送去墓地时，对方受到数值与被破坏怪兽的原本攻击力相同的伤害。
function c86327225.initial_effect(c)
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
-- 判断发动条件：自身仍在战斗中，被破坏的怪兽已送去墓地且是怪兽卡，且被破坏时是守备表示
function c86327225.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
		and bit.band(bc:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 设置效果发动的目标：获取被破坏怪兽的原本攻击力，并设定伤害的对象玩家、伤害数值和操作信息
function c86327225.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	-- 将伤害的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害的对象参数设置为被破坏怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息，表示该效果会给对方造成对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：获取设定的对象玩家和伤害数值，并给予对方效果伤害
function c86327225.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给予目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
