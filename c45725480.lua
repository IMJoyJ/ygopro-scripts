--七星の宝刀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只7星怪兽除外才能发动。自己从卡组抽2张。
function c45725480.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45725480+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c45725480.cost)
	e1:SetTarget(c45725480.target)
	e1:SetOperation(c45725480.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义了用于筛选7星怪兽的过滤函数
function c45725480.filter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsLevel(7) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：处理发动时的费用，需要除外1只7星怪兽
function c45725480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足除外1只7星怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c45725480.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c45725480.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 效果作用：将选中的卡除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果作用：设置发动效果的目标参数
function c45725480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置效果的目标参数为2
	Duel.SetTargetParam(2)
	-- 效果作用：设置操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：执行效果的发动处理，进行抽卡
function c45725480.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
