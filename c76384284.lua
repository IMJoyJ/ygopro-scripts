--トロイの剣闘獣
-- 效果：
-- 从自己手卡把1只名字带有「剑斗兽」的怪兽在对方场上特殊召唤。那之后，从自己卡组抽1张卡。
function c76384284.initial_effect(c)
	-- 从自己手卡把1只名字带有「剑斗兽」的怪兽在对方场上特殊召唤。那之后，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c76384284.target)
	e1:SetOperation(c76384284.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选手卡中可以特殊召唤到对方场上的「剑斗兽」怪兽
function c76384284.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 发动准备：检查对方场上是否有空位、手卡是否有可特召的「剑斗兽」以及自身是否能抽卡
function c76384284.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查自己手卡是否存在满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c76384284.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置特殊召唤的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置抽卡的操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：特殊召唤手卡的「剑斗兽」怪兽到对方场上，之后抽1张卡
function c76384284.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时对方场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c76384284.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选择，则将该怪兽特殊召唤到对方场上，并判断是否特殊召唤成功
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续的抽卡处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
