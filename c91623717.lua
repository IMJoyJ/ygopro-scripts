--連鎖爆撃
-- 效果：
-- 连锁2以后才能发动。给与对方基本分这张卡的发动时积累的连锁数量×400的数值的伤害。同一连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
function c91623717.initial_effect(c)
	-- 连锁2以后才能发动。给与对方基本分这张卡的发动时积累的连锁数量×400的数值的伤害。同一连锁上有复数次同名卡的效果发动的场合，这张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c91623717.condition)
	e1:SetTarget(c91623717.target)
	e1:SetOperation(c91623717.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否满足发动时机
function c91623717.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须在连锁2及以上发动，且当前连锁中不能有同名卡的效果重复发动
	return Duel.GetCurrentChain()>0 and Duel.CheckChainUniqueness()
end
-- 定义效果的目标处理函数，用于在发动时确定伤害对象和伤害数值
function c91623717.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害数值，等于当前连锁数乘以400
	local dam=Duel.GetCurrentChain()*400
	-- 将计算出的伤害数值设定为效果的对象参数
	Duel.SetTargetParam(dam)
	-- 设置操作信息，声明该效果会给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义效果处理函数，在效果结算时执行伤害操作
function c91623717.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成由效果引起的相应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
