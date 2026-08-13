--地獄戦士
-- 效果：
-- 这张卡因对方怪兽的攻击破坏送去墓地时，也给与对方基本分这次战斗让自己受到的战斗伤害。
function c50916353.initial_effect(c)
	-- 这张卡因对方怪兽的攻击破坏送去墓地时，也给与对方基本分这次战斗让自己受到的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50916353,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c50916353.damcon)
	e1:SetTarget(c50916353.damtg)
	e1:SetOperation(c50916353.damop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：该卡被战斗破坏后位于墓地（ev==1表示战斗破坏），满足时效果才能发动。
function c50916353.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==1 and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 发动时的目标处理与操作信息设定：获取本次战斗自己受到的伤害，若伤害大于0则合法发动，并将对方设为对象玩家、伤害值设为对象参数，同时设置伤害类操作信息。
function c50916353.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取这张卡的控制者（玩家tp）在本次战斗中受到的战斗伤害数值。
	local damage=Duel.GetBattleDamage(tp)
	if chk==0 then return damage>0 end
	-- 将效果的对象玩家设置为对手（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设置为要给予对方的伤害数值damage。
	Duel.SetTargetParam(damage)
	-- 设置当前连锁的操作信息，声明这是一个伤害效果，目标玩家为对方，附带伤害参数（取自效果的Label值）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理时的操作：从连锁信息中取出目标玩家和伤害值，并给对方造成对应伤害。
function c50916353.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前设置的目标玩家p和伤害参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因向目标玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
