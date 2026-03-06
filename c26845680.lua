--オルフェゴール・プライム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只「自奏圣乐」怪兽或「星遗物」怪兽送去墓地才能发动。自己抽2张。
function c26845680.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26845680+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c26845680.cost)
	e1:SetTarget(c26845680.target)
	e1:SetOperation(c26845680.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「自奏圣乐」或「星遗物」怪兽
function c26845680.costfilter(c)
	return c:IsSetCard(0xfe,0x11b) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToGraveAsCost()
end
-- 效果作用：检索满足条件的卡片组并将其送去墓地作为发动代价
function c26845680.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否拥有满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c26845680.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果作用：选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c26845680.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：将选中的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果原文内容：①：从自己的手卡·场上（表侧表示）把1只「自奏圣乐」怪兽或「星遗物」怪兽送去墓地才能发动。自己抽2张。
function c26845680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁的目标参数为2
	Duel.SetTargetParam(2)
	-- 效果作用：设置连锁的操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行抽卡效果
function c26845680.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
