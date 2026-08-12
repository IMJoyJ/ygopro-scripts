--コアキメイル・ウルナイト
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。1回合1次，可以把手卡1张「核成兽的钢核」给对方观看，从自己卡组把「核成原始骑士」以外的1只4星以下的名字带有「核成」的怪兽特殊召唤。
function c30936186.initial_effect(c)
	-- 记录该卡具有「核成兽的钢核」这张卡的卡片密码
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c30936186.mtcon)
	e1:SetOperation(c30936186.mtop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把手卡1张「核成兽的钢核」给对方观看，从自己卡组把「核成原始骑士」以外的1只4星以下的名字带有「核成」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30936186,3))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30936186.spcost)
	e2:SetTarget(c30936186.sptg)
	e2:SetOperation(c30936186.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为当前回合玩家触发效果
function c30936186.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家触发效果
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手卡中可送入墓地的「核成兽的钢核」
function c30936186.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤手卡中未公开的兽战士族怪兽
function c30936186.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEASTWARRIOR) and not c:IsPublic()
end
-- 处理结束阶段效果选择与执行
function c30936186.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡显示选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取手卡中可送入墓地的「核成兽的钢核」组
	local g1=Duel.GetMatchingGroup(c30936186.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取手卡中未公开的兽战士族怪兽组
	local g2=Duel.GetMatchingGroup(c30936186.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 选择执行结束阶段效果：送墓/给对方观看/破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(30936186,0),aux.Stringid(30936186,1),aux.Stringid(30936186,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张兽战士族怪兽给对方观看/破坏「核成原始骑士」"
	elseif g1:GetCount()>0 then
		-- 选择执行结束阶段效果：送墓/破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(30936186,0),aux.Stringid(30936186,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成原始骑士」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 选择执行结束阶段效果：给对方观看/破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(30936186,1),aux.Stringid(30936186,2))+1  --"选择一张兽战士族怪兽给对方观看/破坏「核成原始骑士」"
	else
		-- 选择执行结束阶段效果：破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(30936186,2))  --"破坏「核成原始骑士」"
		select=2
	end
	if select==0 then
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
	else
		-- 破坏自身
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤手卡中未公开的「核成兽的钢核」
function c30936186.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 支付特殊召唤效果的费用：确认一张手卡中的「核成兽的钢核」
function c30936186.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c30936186.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手卡中的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c30936186.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤卡组中满足特殊召唤条件的怪兽
function c30936186.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1d) and not c:IsCode(30936186) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标与条件检查
function c30936186.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c30936186.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果
function c30936186.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c30936186.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
