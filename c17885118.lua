--ペンデュラム・スケール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的灵摆区域有2张卡存在的场合，那个灵摆刻度差的数值的以下效果适用。
-- ●0：选场上2张魔法·陷阱卡破坏。
-- ●1～3：从卡组把1只2～4星的灵摆怪兽加入手卡。
-- ●4～6：从卡组把1只5～7星的灵摆怪兽加入手卡。
-- ●7以上：选自己的灵摆区域最多2张卡回到持有者手卡。那之后，可以从手卡把1只灵摆怪兽特殊召唤。
function c17885118.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、时点、发动限制、条件、目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17885118,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17885118+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17885118.condition)
	e1:SetTarget(c17885118.target)
	e1:SetOperation(c17885118.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：自己的灵摆区域有2张卡存在
function c17885118.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的灵摆区域是否有2张卡
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==2
end
-- 破坏效果的过滤函数：筛选魔法·陷阱卡
function c17885118.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检索效果的过滤函数1：筛选2～4星的灵摆怪兽
function c17885118.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(2) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 检索效果的过滤函数2：筛选5～7星的灵摆怪兽
function c17885118.thfilter2(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(5) and c:IsLevelBelow(7) and c:IsAbleToHand()
end
-- 设置效果的目标函数，根据灵摆刻度差决定可发动的效果类型
function c17885118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家灵摆区域第1个位置的卡
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取玩家灵摆区域第2个位置的卡
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	local dif=math.abs(scl1-scl2)
	if chk==0 then return
		-- 当灵摆刻度差为0时，检查场上是否存在2张魔法·陷阱卡
		(dif==0 and Duel.IsExistingMatchingCard(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()))
		-- 当灵摆刻度差为1～3时，检查卡组是否存在1张2～4星的灵摆怪兽
		or (dif>=1 and dif<=3 and Duel.IsExistingMatchingCard(c17885118.thfilter1,tp,LOCATION_DECK,0,1,nil))
		-- 当灵摆刻度差为4～6时，检查卡组是否存在1张5～7星的灵摆怪兽
		or (dif>=4 and dif<=6 and Duel.IsExistingMatchingCard(c17885118.thfilter2,tp,LOCATION_DECK,0,1,nil))
		-- 当灵摆刻度差为7以上时，检查自己的灵摆区域是否存在至少1张可返回手卡的卡
		or (dif>=7 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)) end
	if dif==0 then
		-- 获取场上所有魔法·陷阱卡的集合
		local g=Duel.GetMatchingGroup(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		-- 设置连锁操作信息：破坏2张魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	end
	-- 设置连锁操作信息：从卡组检索1张灵摆怪兽加入手卡
	if dif>=1 and dif<=6 then Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
end
-- 效果处理函数，根据灵摆刻度差执行不同的效果
function c17885118.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的灵摆区域是否有2张卡，否则不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)<2 then return end
	-- 获取玩家灵摆区域第1个位置的卡
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取玩家灵摆区域第2个位置的卡
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	local dif=math.abs(scl1-scl2)
	-- 获取场上所有魔法·陷阱卡的集合
	local g1=Duel.GetMatchingGroup(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 获取卡组中所有2～4星灵摆怪兽的集合
	local g2=Duel.GetMatchingGroup(c17885118.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 获取卡组中所有5～7星灵摆怪兽的集合
	local g3=Duel.GetMatchingGroup(c17885118.thfilter2,tp,LOCATION_DECK,0,nil)
	-- 获取玩家灵摆区域所有可返回手卡的卡的集合
	local g4=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_PZONE,0,nil)
	local b1=dif==0 and g1:GetCount()>=2
	local b2=dif>=1 and dif<=3 and g2:GetCount()>=1
	local b3=dif>=4 and dif<=6 and g3:GetCount()>=1
	local b4=dif>=7 and g4:GetCount()>=1
	if b1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g1:Select(tp,2,2,e:GetHandler())
		-- 将选中的卡破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
	if b2 then
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g2:Select(tp,1,1,nil)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认选中的卡
		Duel.ConfirmCards(1-tp,sg)
	end
	if b3 then
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g3:Select(tp,1,1,nil)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认选中的卡
		Duel.ConfirmCards(1-tp,sg)
	end
	if b4 then
		-- 提示玩家选择要返回手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local sg=g4:Select(tp,1,2,nil)
		-- 将选中的卡返回手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 获取玩家手卡中所有可特殊召唤的灵摆怪兽集合
		local fg=Duel.GetMatchingGroup(c17885118.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检查玩家场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and fg:GetCount()>0
			-- 询问玩家是否从手卡特殊召唤灵摆怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(17885118,1)) then  --"是否从手卡把灵摆怪兽特殊召唤？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local mg=fg:Select(tp,1,1,nil)
			-- 将选中的灵摆怪兽特殊召唤
			Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 特殊召唤的过滤函数：筛选可特殊召唤的灵摆怪兽
function c17885118.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
