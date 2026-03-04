--サイコ・フィール・ゾーン
-- 效果：
-- 让从游戏中除外的自己1只念动力族的调整和1只调整以外的念动力族怪兽回到墓地，和那个等级合计相同等级的1只念动力族的同调怪兽从额外卡组表侧守备表示特殊召唤。
function c11047543.initial_effect(c)
	-- 卡片效果初始化，设置效果描述、类别、类型、时点、属性、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11047543,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11047543.target)
	e1:SetOperation(c11047543.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数1：选择满足条件的念动力族调整怪兽
function c11047543.filter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_TUNER)
		-- 检查是否存在满足条件的念动力族非调整怪兽作为第二目标
		and Duel.IsExistingTarget(c11047543.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤函数2：选择满足条件的念动力族非调整怪兽
function c11047543.filter2(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsType(TYPE_TUNER)
		-- 检查额外卡组中是否存在满足等级条件的念动力族同调怪兽
		and Duel.IsExistingMatchingCard(c11047543.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
-- 同调怪兽特殊召唤的过滤函数
function c11047543.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv)
		-- 检查同调怪兽是否可以特殊召唤且场上存在召唤区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理的目标选择函数
function c11047543.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足发动条件，检查是否存在满足条件的除外怪兽
	if chk==0 then return Duel.IsExistingTarget(c11047543.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的除外念动力族调整怪兽
	local g1=Duel.SelectTarget(tp,c11047543.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的除外念动力族非调整怪兽
	local g2=Duel.SelectTarget(tp,c11047543.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,g1:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 设置操作信息：将选择的2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置操作信息：准备特殊召唤1只同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c11047543.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的选中目标
	local g=Duel.GetTargetsRelateToChain()
	-- 检查选中目标数量是否为2并将其送去墓地
	if g:GetCount()~=2 or Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)~=2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	-- 根据选中怪兽等级总和，检索满足条件的同调怪兽
	local sg=Duel.GetMatchingGroup(c11047543.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetLevel()+tc2:GetLevel())
	if sg:GetCount()==0 then return end
	-- 中断当前效果处理，使后续处理视为错时点
	Duel.BreakEffect()
	-- 提示玩家选择要特殊召唤的同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ssg=sg:Select(tp,1,1,nil)
	-- 将选中的同调怪兽从额外卡组表侧守备表示特殊召唤
	Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
