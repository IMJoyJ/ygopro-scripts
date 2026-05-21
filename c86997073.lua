--機動要塞フォルテシモ
-- 效果：
-- 1回合1次，可以从自己手卡把1只名字带有「机皇兵」的怪兽在自己场上特殊召唤。
function c86997073.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从自己手卡把1只名字带有「机皇兵」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86997073,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTarget(c86997073.target)
	e1:SetOperation(c86997073.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中名字带有「机皇兵」且可以特殊召唤的怪兽
function c86997073.filter(c,e,sp)
	return c:IsSetCard(0x6013) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动阶段：检查自己场上是否有空怪兽区域，以及手牌中是否存在满足条件的怪兽
function c86997073.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c86997073.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：从手牌选择1只名字带有「机皇兵」的怪兽特殊召唤到场上
function c86997073.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c86997073.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
