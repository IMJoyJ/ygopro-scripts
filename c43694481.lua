--ブリザード・ファルコン
-- 效果：
-- 这张卡的攻击力比原本攻击力高的场合才能发动。给与对方基本分1500分伤害。这个效果只在这张卡在场上表侧表示存在能使用1次，「雪暴猎鹰」的效果1回合只能使用1次。
function c43694481.initial_effect(c)
	-- 这张卡的攻击力比原本攻击力高的场合才能发动。
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
-- 检查当前卡的攻击力是否高于原本攻击力
function c43694481.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttack()>e:GetHandler():GetBaseAttack()
end
-- 设置连锁处理目标为对方玩家，伤害值为1500
function c43694481.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为1500
	Duel.SetTargetParam(1500)
	-- 设置连锁操作信息为造成1500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 执行伤害效果，对对方玩家造成1500点伤害
function c43694481.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
