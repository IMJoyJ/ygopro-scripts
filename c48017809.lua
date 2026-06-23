--蜃気楼の筒
-- 效果：
-- 这张卡不能从手卡发动。自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。给与对方基本分1000分伤害。
function c48017809.initial_effect(c)
	-- 这张卡不能从手卡发动。自己场上表侧表示存在的怪兽被选择作为攻击对象时才能发动。给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c48017809.condition)
	e1:SetTarget(c48017809.target)
	e1:SetOperation(c48017809.activate)
	c:RegisterEffect(e1)
end
-- 效果适用条件：这张卡不在手卡且攻击对象是自己场上的表侧表示怪兽
function c48017809.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLocation(LOCATION_HAND)
		and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsFaceup()
end
-- 效果处理目标：设定伤害对象为对方玩家，伤害值为1000
function c48017809.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为伤害效果，影响对方玩家，伤害值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果发动时的处理函数：获取连锁中的目标玩家和参数并造成相应伤害
function c48017809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
