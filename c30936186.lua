--コアキメイル・ウルナイト
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地或把手卡1只兽战士族怪兽给对方观看。或者都不进行让这张卡破坏。1回合1次，可以把手卡1张「核成兽的钢核」给对方观看，从自己卡组把「核成原始骑士」以外的1只4星以下的名字带有「核成」的怪兽特殊召唤。
function c30936186.initial_effect(c)
	-- 将「核成兽的钢核」（卡号36623431）登记为该卡涉及的卡名，以便相关效果识别该卡名。
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
-- e1的发动条件：当前回合玩家是这张卡的控制者，即只在控制者的结束阶段判定是否进行维持行为。
function c30936186.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前回合玩家是否等于这张卡的控制者（tp），是则返回true。
	return Duel.GetTurnPlayer()==tp
end
-- 定义过滤器cfilter1：筛选手卡中卡号为36623431的「核成兽的钢核」，且可以作为代价送入墓地。
function c30936186.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 定义过滤器cfilter2：筛选手卡中未公开的兽战士族怪兽，用于选择给对方观看。
function c30936186.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_BEASTWARRIOR) and not c:IsPublic()
end
-- e1的操作函数：在结束阶段让控制者选择执行维持行为——从手卡将1张「核成兽的钢核」送入墓地，或展示1只兽战士族怪兽；若无对应卡片或选择不进行，则破坏这张卡。
function c30936186.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向双方玩家展示这张卡被选中为效果处理对象，播放选中动画。
	Duel.HintSelection(Group.FromCards(c))
	-- 获取控制者手卡中所有满足cfilter1的「核成兽的钢核」（可作为代价送墓），存入g1。
	local g1=Duel.GetMatchingGroup(c30936186.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取控制者手卡中所有满足cfilter2的未公开兽战士族怪兽，存入g2。
	local g2=Duel.GetMatchingGroup(c30936186.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 弹出三选一菜单：送墓「核成兽的钢核」/展示兽战士族怪兽/破坏自身，记录选择序号。
		select=Duel.SelectOption(tp,aux.Stringid(30936186,0),aux.Stringid(30936186,1),aux.Stringid(30936186,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张兽战士族怪兽给对方观看/破坏「核成原始骑士」"
	elseif g1:GetCount()>0 then
		-- 当只有送墓钢核可用时，弹出两选一菜单：送墓钢核或破坏自身；若选择破坏自身，将选择映射为2。
		select=Duel.SelectOption(tp,aux.Stringid(30936186,0),aux.Stringid(30936186,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成原始骑士」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 当只有展示兽战士可用时，弹出两选一菜单：展示兽战士或破坏自身；因选项从0开始，对返回值+1将选项映射为1/2。
		select=Duel.SelectOption(tp,aux.Stringid(30936186,1),aux.Stringid(30936186,2))+1  --"选择一张兽战士族怪兽给对方观看/破坏「核成原始骑士」"
	else
		-- 当两者都不可用时，只有一个选项破坏自身，强制select=2。
		select=Duel.SelectOption(tp,aux.Stringid(30936186,2))  --"破坏「核成原始骑士」"
		select=2
	end
	if select==0 then
		-- 发送提示信息，提示控制者选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为维持代价送入墓地。
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 发送提示信息，提示控制者选择给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选中的手卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 因手卡被展示过，洗切控制者的手卡以隐藏顺序。
		Duel.ShuffleHand(tp)
	else
		-- 控制者未进行维持行为时，将这张卡破坏（作为规则代价）。
		Duel.Destroy(c,REASON_COST)
	end
end
-- 定义过滤器cfilter：筛选手卡中卡号为36623431的「核成兽的钢核」，且处于非公开状态，用作起动效果的展示费用。
function c30936186.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- e2的费用函数：确认手卡存在可展示的「核成兽的钢核」；选择1张展示给对方，然后洗切手卡。
function c30936186.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用合法性检查：手卡中是否存在至少1张满足cfilter的「核成兽的钢核」。
	if chk==0 then return Duel.IsExistingMatchingCard(c30936186.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 发送提示信息，提示控制者选择给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让控制者从手卡选择1张「核成兽的钢核」作为展示费用。
	local g=Duel.SelectMatchingCard(tp,c30936186.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的「核成兽的钢核」展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 因手卡被展示过，洗切控制者的手卡。
	Duel.ShuffleHand(tp)
end
-- 定义spfilter：筛选等级4以下、字段为「核成」（0x1d）、不是「核成原始骑士」自身、且能被当前效果特殊召唤的怪兽。
function c30936186.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1d) and not c:IsCode(30936186) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- e2的目标函数：发动条件检查：自己场上有可用的怪兽区域且卡组中存在符合条件的怪兽。
function c30936186.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：控制者场上怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之二：卡组中存在1只满足spfilter的特殊召唤候选怪兽。
		and Duel.IsExistingMatchingCard(c30936186.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果信息：本效果会从卡组特殊召唤1只怪兽（目标区域为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- e2的操作函数：效果处理时从卡组选择1只符合条件的「核成」怪兽特殊召唤到控制者场上。
function c30936186.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上是否有空位，没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，提示控制者选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,c30936186.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到控制者场上（sumtype为0，会检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
