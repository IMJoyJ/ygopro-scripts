--兵隊竜
-- 效果：
-- ①：1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组把1只2星以下的龙族怪兽特殊召唤。
function c7805147.initial_effect(c)
	-- ①：1回合1次，对方把魔法·陷阱·怪兽的效果发动时才能发动。从卡组把1只2星以下的龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7805147,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c7805147.condition)
	e1:SetTarget(c7805147.target)
	e1:SetOperation(c7805147.operation)
	c:RegisterEffect(e1)
end
-- 检查发动效果的玩家是否为对方
function c7805147.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤卡组中等级2以下、龙族且可以特殊召唤的怪兽
function c7805147.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与准备
function c7805147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c7805147.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c7805147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c7805147.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
