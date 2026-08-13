--デス・メテオ
-- 效果：
-- 给与对方基本分1000分伤害。对方基本分是3000以下的场合这张卡不能发动。
function c33767325.initial_effect(c)
	-- 给与对方基本分1000分伤害。对方基本分是3000以下的场合这张卡不能发动。
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
-- 发动条件判定：仅当对方基本分高于3000时，这张卡才能发动。
function c33767325.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方基本分，判断是否大于3000，作为发动条件。
	return Duel.GetLP(1-tp)>3000
end
-- 效果发动时的目标处理：将对象玩家设为对方，伤害值设为1000，并登记伤害效果的操作信息。
function c33767325.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000，即要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：效果分类为伤害，目标玩家为对方，伤害数值为1000，供后续效果处理及对方连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理时：从连锁信息中取出记录的目标玩家和伤害参数，给对方造成1000点伤害。
function c33767325.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和伤害参数，分别赋给变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
