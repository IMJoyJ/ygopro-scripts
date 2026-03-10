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
-- 效果发动条件：战斗破坏且自身在墓地
function c50916353.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==1 and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果处理目标：将对方玩家设为伤害对象，伤害值为自己本次战斗受到的伤害
function c50916353.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家在本次战斗中受到的伤害值
	local damage=Duel.GetBattleDamage(tp)
	if chk==0 then return damage>0 end
	-- 设置连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为自身受到的战斗伤害值
	Duel.SetTargetParam(damage)
	-- 设置本次连锁的操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 效果处理执行：从连锁信息中获取目标玩家和伤害值并造成伤害
function c50916353.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
