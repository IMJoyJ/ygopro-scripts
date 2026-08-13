--子狸たんたん
-- 效果：
-- 反转：从卡组把「子狸 当当」以外的1只兽族·2星怪兽特殊召唤。
function c28118128.initial_effect(c)
	-- 反转：从卡组把「子狸 当当」以外的1只兽族·2星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28118128,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c28118128.target)
	e1:SetOperation(c28118128.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的发动时点：确认效果发动条件满足（无条件）并登记特殊召唤卡组的操作信息。
function c28118128.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁将从卡组把1只怪兽特殊召唤的处理信息，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义筛选条件：从卡组选择1只卡名不为「子狸 当当」、等级2、兽族且可以被特殊召唤的怪兽。
function c28118128.filter(c,e,tp)
	return not c:IsCode(28118128) and c:IsLevel(2) and c:IsRace(RACE_BEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段：先确认自己的主要怪兽区域有空位，再让玩家选择符合条件的卡并对其进行特殊召唤。
function c28118128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区域是否至少有1个空闲格子，若没有则不进行后续特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中选出1张满足过滤器条件的卡片（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c28118128.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击/防御表示特殊召唤到自己的主要怪兽区域，不检查苏生限制等条件。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
