--ハチビー
-- 效果：
-- 把这张卡和自己场上表侧表示存在的「小蜜蜂」以外的1只昆虫族怪兽解放发动。从自己卡组抽2张卡。
function c1474910.initial_effect(c)
	-- 把这张卡和自己场上表侧表示存在的「小蜜蜂」以外的1只昆虫族怪兽解放发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1474910,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c1474910.cost)
	e1:SetTarget(c1474910.target)
	e1:SetOperation(c1474910.operation)
	c:RegisterEffect(e1)
end
-- 用于筛选满足条件的昆虫族怪兽（不包括小蜜蜂）
function c1474910.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and not c:IsCode(1474910)
end
-- 效果的费用处理函数，用于判断是否可以支付费用并选择解放的怪兽
function c1474910.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放自身以及场上是否存在满足条件的怪兽
	if chk==0 then return e:GetHandler():IsReleasable() and Duel.CheckReleaseGroup(tp,c1474910.cfilter,1,nil) end
	-- 选择1只满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c1474910.cfilter,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽解放作为效果的费用
	Duel.Release(g,REASON_COST)
end
-- 效果的目标设定函数，用于判断是否可以发动效果
function c1474910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置效果的操作信息为抽卡效果，目标为当前玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果的发动处理函数，用于执行效果的最终处理
function c1474910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
