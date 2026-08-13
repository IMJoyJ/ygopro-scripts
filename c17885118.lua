--ペンデュラム・スケール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的灵摆区域有2张卡存在的场合，那个灵摆刻度差的数值的以下效果适用。
-- ●0：选场上2张魔法·陷阱卡破坏。
-- ●1～3：从卡组把1只2～4星的灵摆怪兽加入手卡。
-- ●4～6：从卡组把1只5～7星的灵摆怪兽加入手卡。
-- ●7以上：选自己的灵摆区域最多2张卡回到持有者手卡。那之后，可以从手卡把1只灵摆怪兽特殊召唤。
function c17885118.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的灵摆区域有2张卡存在的场合，那个灵摆刻度差的数值的以下效果适用。●0：选场上2张魔法·陷阱卡破坏。●1～3：从卡组把1只2～4星的灵摆怪兽加入手卡。●4～6：从卡组把1只5～7星的灵摆怪兽加入手卡。●7以上：选自己的灵摆区域最多2张卡回到持有者手卡。那之后，可以从手卡把1只灵摆怪兽特殊召唤。
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
-- 效果发动的条件判断函数：检查自己的灵摆区域是否有2张卡存在，满足①效果发动的场合条件。
function c17885118.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己灵摆区域卡牌数量是否恰好为2张，作为效果能否发动的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==2
end
-- 定义刻度差为0时破坏对象的过滤器：选择场上魔法·陷阱卡（包括永续魔法/陷阱等）。
function c17885118.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义刻度差1～3时检索对象的过滤器：从卡组选择等级2～4的灵摆怪兽且能够加入手卡。
function c17885118.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(2) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 定义刻度差4～6时检索对象的过滤器：从卡组选择等级5～7的灵摆怪兽且能够加入手卡。
function c17885118.thfilter2(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelAbove(5) and c:IsLevelBelow(7) and c:IsAbleToHand()
end
-- 效果发动时的合法性检查部分：读取自己灵摆区域左右两格卡片并计算刻度差，根据刻度差的不同范围判断场上或卡组中是否存在对应的可处理对象，以决定该效果能否发动。
function c17885118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己灵摆区域左侧（序号0）的卡片。
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取自己灵摆区域右侧（序号1）的卡片。
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	local dif=math.abs(scl1-scl2)
	if chk==0 then return
		-- 刻度差为0时，检查双方场上是否存在至少2张魔法·陷阱卡（不包含本卡）可作为破坏对象。
		(dif==0 and Duel.IsExistingMatchingCard(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()))
		-- 刻度差在1～3之间时，检查自己卡组中是否存在1只等级2～4且可加入手卡的灵摆怪兽作为检索对象。
		or (dif>=1 and dif<=3 and Duel.IsExistingMatchingCard(c17885118.thfilter1,tp,LOCATION_DECK,0,1,nil))
		-- 刻度差在4～6之间时，检查自己卡组中是否存在1只等级5～7且可加入手卡的灵摆怪兽作为检索对象。
		or (dif>=4 and dif<=6 and Duel.IsExistingMatchingCard(c17885118.thfilter2,tp,LOCATION_DECK,0,1,nil))
		-- 刻度差为7以上时，检查自己的灵摆区域是否存在至少1张能够回到手卡的卡作为回手对象。
		or (dif>=7 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil)) end
	if dif==0 then
		-- 取得场上所有魔法·陷阱卡（排除本卡）的集合，作为刻度差0时的破坏候选组。
		local g=Duel.GetMatchingGroup(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		-- 设置本连锁的操作信息为破坏效果：对象为场上魔法·陷阱卡候选组，数量为2，使相关卡能正确响应破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	end
	-- 刻度差在1～6之间时，设置操作信息为从卡组将1张卡加入手卡的检索效果。
	if dif>=1 and dif<=6 then Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
end
-- 效果处理函数：根据刻度差执行对应的分支效果；若灵摆区域卡数不足2张则直接终止。包括破坏、检索、回手和特殊召唤处理。
function c17885118.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己的灵摆区域仍有2张卡，否则不进行后续处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)<2 then return end
	-- 处理时再次取得灵摆区域左格卡片。
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 处理时再次取得灵摆区域右格卡片。
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	local dif=math.abs(scl1-scl2)
	-- 取得场上魔法·陷阱卡集合（排除本卡），作为刻度差0时的破坏候选组。
	local g1=Duel.GetMatchingGroup(c17885118.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 取得卡组中满足等级2～4灵摆怪兽检索条件的卡片集合，用于刻度差1～3分支。
	local g2=Duel.GetMatchingGroup(c17885118.thfilter1,tp,LOCATION_DECK,0,nil)
	-- 取得卡组中满足等级5～7灵摆怪兽检索条件的卡片集合，用于刻度差4～6分支。
	local g3=Duel.GetMatchingGroup(c17885118.thfilter2,tp,LOCATION_DECK,0,nil)
	-- 取得自己灵摆区域中能够回到手卡的卡集合，用于刻度差7以上分支。
	local g4=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_PZONE,0,nil)
	local b1=dif==0 and g1:GetCount()>=2
	local b2=dif>=1 and dif<=3 and g2:GetCount()>=1
	local b3=dif>=4 and dif<=6 and g3:GetCount()>=1
	local b4=dif>=7 and g4:GetCount()>=1
	if b1 then
		-- 发送选择提示：请选择要破坏的卡，进入选择界面时显示该提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g1:Select(tp,2,2,e:GetHandler())
		-- 将选择的两张魔法·陷阱卡以效果原因破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
	if b2 then
		-- 发送选择提示：请选择要加入手牌的卡（用于检索选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g2:Select(tp,1,1,nil)
		-- 将选择检索到的卡加入持有者手牌（nil表示回到持有者手牌），原因记为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,sg)
	end
	if b3 then
		-- 发送选择提示：请选择要加入手牌的卡（用于第二段检索选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g3:Select(tp,1,1,nil)
		-- 将选择检索到的卡加入持有者手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,sg)
	end
	if b4 then
		-- 发送选择提示：请选择要返回手牌的卡（用于选择灵摆区的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local sg=g4:Select(tp,1,2,nil)
		-- 将选择灵摆区域卡返回持有者手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 取得手牌中满足可特殊召唤条件的灵摆怪兽集合，用于后续可选特殊召唤。
		local fg=Duel.GetMatchingGroup(c17885118.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检查自己主要怪兽区是否有空位，并且手牌中存在可特殊召唤的灵摆怪兽，作为是否询问特殊召唤的条件。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and fg:GetCount()>0
			-- 询问玩家是否要特殊召唤手牌的灵摆怪兽，选择是则继续，否则跳过特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(17885118,1)) then  --"是否从手卡把灵摆怪兽特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤作为单独处理，错开时点。
			Duel.BreakEffect()
			-- 发送选择提示：请选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local mg=fg:Select(tp,1,1,nil)
			-- 将选择的手牌灵摆怪兽以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 特殊召唤的过滤函数：判断手牌中的灵摆怪兽是否满足本次效果的特殊召唤条件（含召唤条件/苏生限制检查）。
function c17885118.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
