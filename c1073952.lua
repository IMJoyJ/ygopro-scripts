--マジック・プランター
-- 效果：
-- ①：把自己场上1张表侧表示的永续陷阱卡送去墓地才能发动。自己抽2张。
function c1073952.initial_effect(c)
	-- 效果原文内容：①：把自己场上1张表侧表示的永续陷阱卡送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c1073952.cost)
	e1:SetTarget(c1073952.target)
	e1:SetOperation(c1073952.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的卡片
function c1073952.filter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x20004)==0x20004 and c:IsAbleToGraveAsCost()
end
-- 效果的费用处理函数
function c1073952.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c1073952.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡片
	local g=Duel.SelectMatchingCard(tp,c1073952.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡片送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标设定函数
function c1073952.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果的发动处理函数
function c1073952.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
