--デュアル・スコーピオン
-- 效果：
-- 这张卡召唤·特殊召唤成功时，可以从手卡把1只4星以下的二重怪兽特殊召唤。
function c91798373.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，可以从手卡把1只4星以下的二重怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91798373,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c91798373.sumtg)
	e1:SetOperation(c91798373.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为手牌中等级4以下、可以特殊召唤的二重怪兽
function c91798373.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查：确认怪兽区域有空位且手牌中存在符合条件的卡片
function c91798373.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的卡片
		and Duel.IsExistingMatchingCard(c91798373.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数：从手牌选择1只符合条件的二重怪兽特殊召唤
function c91798373.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c91798373.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
