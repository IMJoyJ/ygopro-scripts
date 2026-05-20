--閃刀起動－エンゲージ
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。从卡组把「闪刀起动-交闪」以外的1张「闪刀」卡加入手卡。那之后，自己墓地有魔法卡3张以上存在的场合，自己可以抽1张。
function c63166095.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。从卡组把「闪刀起动-交闪」以外的1张「闪刀」卡加入手卡。那之后，自己墓地有魔法卡3张以上存在的场合，自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c63166095.condition)
	e1:SetTarget(c63166095.target)
	e1:SetOperation(c63166095.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否在主要怪兽区域（格子序号小于5，即不包括额外怪兽区域）
function c63166095.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：自己的主要怪兽区域没有怪兽存在
function c63166095.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域（0-4号格）是否存在怪兽，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c63166095.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：卡组中除「闪刀起动-交闪」以外的「闪刀」卡片，且该卡片可以加入手卡
function c63166095.filter(c)
	return c:IsSetCard(0x115) and c:IsAbleToHand() and not c:IsCode(63166095)
end
-- 效果发动时的目标选择与检测：检查卡组中是否存在可检索的「闪刀」卡，并设置检索和抽卡的操作信息
function c63166095.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「闪刀」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c63166095.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 检查自己墓地的魔法卡数量是否在3张以上
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		-- 设置操作信息：玩家抽1张卡（用于连锁处理时的分类检测）
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 效果处理：从卡组检索「闪刀」卡，并根据墓地魔法卡数量决定是否抽卡
function c63166095.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「闪刀」卡
	local g=Duel.SelectMatchingCard(tp,c63166095.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己当前是否可以抽卡
		if Duel.IsPlayerCanDraw(tp,1)
			-- 并且自己墓地有魔法卡3张以上存在
			and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			-- 并且玩家选择进行抽卡
			and Duel.SelectYesNo(tp,aux.Stringid(63166095,0)) then  --"是否抽卡？"
			-- 插入效果中断，使后续的抽卡处理与前面的检索处理不视为同时进行
			Duel.BreakEffect()
			-- 洗切自己的卡组
			Duel.ShuffleDeck(tp)
			-- 玩家因效果抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
