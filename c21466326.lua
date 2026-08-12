--残骸爆破
-- 效果：
-- 当自己墓地里存在30张以上卡的场合这张卡才能发动。给与对方基本分3000分的伤害。
function c21466326.initial_effect(c)
	-- 卡片效果初始化，创建效果并设置其类型、条件、目标和发动方式
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c21466326.condition)
	e1:SetTarget(c21466326.target)
	e1:SetOperation(c21466326.activate)
	c:RegisterEffect(e1)
end
-- 当自己墓地里存在30张以上卡的场合这张卡才能发动
function c21466326.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己墓地的卡数量是否大于等于30
	return Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=30
end
-- 设置连锁的处理目标为对方玩家并设定伤害值
function c21466326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为3000
	Duel.SetTargetParam(3000)
	-- 设置连锁的操作信息为对对方造成3000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,3000)
end
-- 执行效果的处理函数，对对方造成指定伤害
function c21466326.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成对应伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
