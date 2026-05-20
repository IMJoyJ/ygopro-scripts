--ナーガ
-- 效果：
-- ①：表侧表示的这张卡从场上回到卡组的场合发动。从卡组把1只3星以下的怪兽特殊召唤。
function c71829750.initial_effect(c)
	-- ①：表侧表示的这张卡从场上回到卡组的场合发动。从卡组把1只3星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71829750,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCondition(c71829750.spcon)
	e1:SetTarget(c71829750.sptg)
	e1:SetOperation(c71829750.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：检查这张卡在回到卡组前是否在场上表侧表示存在
function c71829750.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动靶向：因为是必发效果，在chk==0时直接返回true，并设置特殊召唤的操作信息
function c71829750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：等级3以下且可以特殊召唤的怪兽
function c71829750.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：从卡组选择1只满足条件的怪兽在自身场上表侧表示特殊召唤
function c71829750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c71829750.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
