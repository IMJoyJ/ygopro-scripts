--深海のディーヴァ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只3星以下的海龙族怪兽特殊召唤。
function c78868119.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只3星以下的海龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78868119,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c78868119.sumtg)
	e1:SetOperation(c78868119.sumop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级3以下、海龙族且可以特殊召唤的怪兽
function c78868119.filter(c,e,sp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动的可行性检查（检查卡组中是否存在符合条件的怪兽且自身场上有空余怪兽区域）
function c78868119.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78868119.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁处理的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（从卡组选择1只符合条件的怪兽特殊召唤）
function c78868119.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c78868119.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
