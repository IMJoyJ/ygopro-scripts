--プリーステス・オーム
-- 效果：
-- 可以把自己场上表侧表示存在的1只暗属性怪兽作为祭品，给与对方基本分800分伤害。
function c27869883.initial_effect(c)
	-- 创建效果，设置效果描述为“800伤害”，分类为伤害效果，属性为以玩家为目标，类型为起动效果，生效位置为主怪兽区，设置费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27869883,0))  --"800伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c27869883.damcost)
	e1:SetTarget(c27869883.damtg)
	e1:SetOperation(c27869883.damop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的暗属性怪兽
function c27869883.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 费用处理函数，检查并选择1只满足条件的怪兽进行解放
function c27869883.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,c27869883.cfilter,1,nil) end
	-- 从场上选择1张满足条件的可解放的卡
	local g=Duel.SelectReleaseGroup(tp,c27869883.cfilter,1,1,nil)
	-- 以代价原因解放选中的卡
	Duel.Release(g,REASON_COST)
end
-- 目标设定函数，设置伤害对象为对方玩家，伤害值为800
function c27869883.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为800
	Duel.SetTargetParam(800)
	-- 设置连锁的操作信息，指定伤害效果的目标为对方玩家，伤害值为800
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,800)
end
-- 效果处理函数，根据连锁信息获取目标玩家和伤害值并造成伤害
function c27869883.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
