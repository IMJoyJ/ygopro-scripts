--紅玉の宝札
-- 效果：
-- 「红玉之宝札」在1回合只能发动1张。
-- ①：从手卡把1只7星「真红眼」怪兽送去墓地才能发动。自己从卡组抽2张。那之后，可以从卡组把1只7星「真红眼」怪兽送去墓地。
function c32566831.initial_effect(c)
	-- 效果原文内容：「红玉之宝札」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,32566831+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c32566831.cost)
	e1:SetTarget(c32566831.target)
	e1:SetOperation(c32566831.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义用于筛选手卡中7星真红眼怪兽的过滤函数
function c32566831.cfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevel(7) and c:IsAbleToGraveAsCost()
end
-- 效果作用：支付发动费用，丢弃1只手卡中的7星真红眼怪兽
function c32566831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足支付费用的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c32566831.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：执行丢弃手卡中1只7星真红眼怪兽的操作
	Duel.DiscardHand(tp,c32566831.cfilter,1,1,REASON_COST,nil)
end
-- 效果作用：设置发动效果的目标为自身并设定抽卡数量
function c32566831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 效果作用：设置连锁效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 效果作用：设置连锁效果的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果作用：定义用于筛选卡组中7星真红眼怪兽的过滤函数
function c32566831.tgfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevel(7) and c:IsAbleToGrave()
end
-- 效果作用：执行效果的主要处理流程，包括抽卡和可能的后续墓地操作
function c32566831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行从卡组抽2张卡的操作
	local dr=Duel.Draw(p,d,REASON_EFFECT)
	-- 效果作用：获取卡组中所有满足条件的7星真红眼怪兽
	local g=Duel.GetMatchingGroup(c32566831.tgfilter,p,LOCATION_DECK,0,nil)
	-- 效果作用：判断是否满足后续墓地操作的条件（抽卡成功且卡组有符合条件的怪兽）
	if dr~=0 and g:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(32566831,0)) then  --"是否从卡组把1只7星「真红眼」怪兽送去墓地？"
		-- 效果作用：中断当前效果处理流程，使后续操作视为错时处理
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(p,1,1,nil)
		-- 效果作用：将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
