--炎の魔精イグニス
-- 效果：
-- 把自己场上表侧表示存在的1只炎属性怪兽解放发动。给与对方基本分自己墓地存在的炎属性怪兽数量×100的数值的伤害。
function c79444933.initial_effect(c)
	-- 把自己场上表侧表示存在的1只炎属性怪兽解放发动。给与对方基本分自己墓地存在的炎属性怪兽数量×100的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79444933,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c79444933.damcost)
	e1:SetTarget(c79444933.damtg)
	e1:SetOperation(c79444933.damop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的炎属性怪兽
function c79444933.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果发动代价（Cost）处理函数
function c79444933.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的表侧表示炎属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c79444933.cfilter,1,nil) end
	-- 玩家选择自己场上1只表侧表示的炎属性怪兽
	local g=Duel.SelectReleaseGroup(tp,c79444933.cfilter,1,1,nil)
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果发动目标（Target）处理函数
function c79444933.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_FIRE) end
	-- 计算自己墓地存在的炎属性怪兽数量×100的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)*100
	-- 设置伤害效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的对象参数为计算出的伤害数值
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息为给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam)
end
-- 效果运行（Operation）处理函数
function c79444933.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新计算自己墓地存在的炎属性怪兽数量×100的伤害数值
	local dam=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_FIRE)*100
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给与目标玩家计算出的效果伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
