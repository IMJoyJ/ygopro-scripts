--コンバート・コンタクト
-- 效果：
-- ①：自己场上没有怪兽存在的场合才能发动。从手卡以及卡组把「新空间侠」卡各1张送去墓地。那之后，自己从卡组抽2张。
function c82639107.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。从手卡以及卡组把「新空间侠」卡各1张送去墓地。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c82639107.condition)
	e1:SetTarget(c82639107.target)
	e1:SetOperation(c82639107.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：自己场上没有怪兽存在
function c82639107.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义过滤函数：属于「新空间侠」且可以送去墓地的卡
function c82639107.filter(c)
	return c:IsSetCard(0x1f) and c:IsAbleToGrave()
end
-- 定义发动检测与操作信息设置函数
function c82639107.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己卡组的卡片数量是否至少有3张（1张送墓，2张抽卡）
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 检查手牌中是否存在至少1张满足条件的「新空间侠」卡
		and Duel.IsExistingMatchingCard(c82639107.filter,tp,LOCATION_HAND,0,1,nil)
		-- 检查卡组中是否存在至少1张满足条件的「新空间侠」卡
		and Duel.IsExistingMatchingCard(c82639107.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将进行抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义效果处理函数：从手牌和卡组各送去1张「新空间侠」卡到墓地，然后抽2张卡
function c82639107.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有满足条件的「新空间侠」卡
	local g1=Duel.GetMatchingGroup(c82639107.filter,tp,LOCATION_HAND,0,nil)
	-- 获取卡组中所有满足条件的「新空间侠」卡
	local g2=Duel.GetMatchingGroup(c82639107.filter,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要送去墓地的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要送去墓地的卡组卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的卡送去墓地，并确认其中至少有卡成功进入墓地
		if Duel.SendtoGrave(sg1,REASON_EFFECT)>0 and sg1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
			-- 中断当前效果，使后续的抽卡处理不与送墓同时处理
			Duel.BreakEffect()
			-- 玩家从卡组抽2张卡
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
