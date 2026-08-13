--前線基地
-- 效果：
-- 1回合1次，自己的主要阶段时可以从手卡把1只4星以下的同盟怪兽特殊召唤。
function c46181000.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，自己的主要阶段时可以从手卡把1只4星以下的同盟怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46181000,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c46181000.target)
	e1:SetOperation(c46181000.operation)
	c:RegisterEffect(e1)
end
c46181000.has_text_type=TYPE_UNION
-- 定义特殊召唤的筛选条件：选择手牌中4星以下的同盟怪兽，且该怪兽能够被当前效果特殊召唤。
function c46181000.filter(c,e,sp)
	return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的判定与登记：检查自己场上是否有可用怪兽区且手牌中存在满足条件的同盟怪兽，若满足则设置本效果将进行特殊召唤。
function c46181000.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足条件的4星以下同盟怪兽。
		and Duel.IsExistingMatchingCard(c46181000.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本次效果将进行1只从手卡的特殊召唤，用于连锁检测与操作信息提示。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，若主要怪兽区仍有空位，则从手牌中选择1只满足条件的同盟怪兽，以表侧表示特殊召唤到自己场上。
function c46181000.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区没有空位，则效果处理不适用，直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，引导玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选择1只满足filter条件的同盟怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c46181000.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
