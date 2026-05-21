--予想GUY
-- 效果：
-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把1只4星以下的通常怪兽特殊召唤。
function c911883.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把1只4星以下的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c911883.condition)
	e1:SetTarget(c911883.target)
	e1:SetOperation(c911883.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数
function c911883.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤卡组中4星以下的通常怪兽且能被特殊召唤的卡片
function c911883.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测函数
function c911883.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c911883.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（发动效果的实际执行）函数
function c911883.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c911883.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
