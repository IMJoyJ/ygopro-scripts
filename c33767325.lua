--デス・メテオ
-- 效果：
-- 给与对方基本分1000分伤害。对方基本分是3000以下的场合这张卡不能发动。
function c33767325.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，伤害效果，以玩家为目标，自由时点，条件为对方基本分大于3000，目标函数为damtg，运算函数为damop
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c33767325.condition)
	e1:SetTarget(c33767325.damtg)
	e1:SetOperation(c33767325.damop)
	c:RegisterEffect(e1)
end
-- 对方基本分是3000以下的场合这张卡不能发动。
function c33767325.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方基本分是否大于3000
	return Duel.GetLP(1-tp)>3000
end
-- 设置伤害效果的目标玩家为对方，目标参数为1000，设置操作信息为对对方造成1000伤害
function c33767325.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息为对对方造成1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行伤害效果，从连锁信息中获取目标玩家和伤害值并造成伤害
function c33767325.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
