--ブリザード・ファルコン
-- 效果：
-- 这张卡的攻击力比原本攻击力高的场合才能发动。给与对方基本分1500分伤害。这个效果只在这张卡在场上表侧表示存在能使用1次，「雪暴猎鹰」的效果1回合只能使用1次。
function c43694481.initial_effect(c)
	-- 这张卡的攻击力比原本攻击力高的场合才能发动。给与对方基本分1500分伤害。这个效果只在这张卡在场上表侧表示存在能使用1次，「雪暴猎鹰」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43694481,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1,43694481)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43694481.damcon)
	e1:SetTarget(c43694481.damtg)
	e1:SetOperation(c43694481.damop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查这张卡的当前攻击力是否大于原本攻击力，满足时才允许发动效果，对应效果原文“这张卡的攻击力比原本攻击力高的场合才能发动”。
function c43694481.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack()>e:GetHandler():GetBaseAttack()
end
-- 效果发动时的目标处理：以对方玩家为伤害对象，设置伤害数值为1500，并登记伤害效果的操作信息。
function c43694481.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家（1-tp）设置为该连锁效果的对象玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数设置为1500，表示造成的伤害数值。
	Duel.SetTargetParam(1500)
	-- 登记操作信息：该连锁是伤害效果，目标玩家为对方，伤害值为1500，用于后续处理及被其他效果参考。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 效果处理：读取连锁中登记的对象玩家和伤害参数，并对该玩家造成效果伤害。
function c43694481.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以‘效果’为原因对p玩家造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
