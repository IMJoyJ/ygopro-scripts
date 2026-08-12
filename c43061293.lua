--ファイアーダーツ
-- 效果：
-- 自己手卡0张的时候才能发动。投掷3次骰子。给与对方基本分那个投掷结果的合计数目×100数值的伤害。
function c43061293.initial_effect(c)
	-- 自己手卡0张的时候才能发动。投掷3次骰子。给与对方基本分那个投掷结果的合计数目×100数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c43061293.damcon)
	e1:SetTarget(c43061293.damtg)
	e1:SetOperation(c43061293.damop)
	c:RegisterEffect(e1)
end
-- 定义damcon条件函数，用于检测发动条件是否满足
function c43061293.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己手卡数量是否为0（即手卡为空）
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义damg目标函数，设置连锁目标玩家和操作信息
function c43061293.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的目标玩家为对方玩家（1-tp）
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息为CATEGORY_DICE类型，表示本次连锁涉及骰子投掷，参数3表示投掷3次
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,3)
	-- 设置操作信息为CATEGORY_DAMAGE类型，表示本次连锁涉及伤害，目标玩家为对方（1-tp）
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 定义damop效果处理函数，执行骰子投掷并造成伤害
function c43061293.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取目标玩家（即对方玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让己方玩家投掷3次骰子，并分别获取三次结果d1、d2、d3
	local d1,d2,d3=Duel.TossDice(tp,3)
	-- 对目标玩家造成（d1+d2+d3）×100点伤害，伤害原因为REASON_EFFECT
	Duel.Damage(p,(d1+d2+d3)*100,REASON_EFFECT)
end
