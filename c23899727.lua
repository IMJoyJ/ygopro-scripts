--水精鱗－アビスリンデ
-- 效果：
-- 场上的这张卡被破坏送去墓地的场合，可以从卡组把「水精鳞-深渊琳德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊琳德」的效果1回合只能使用1次。
function c23899727.initial_effect(c)
	-- 效果原文：场上的这张卡被破坏送去墓地的场合，可以从卡组把「水精鳞-深渊琳德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23899727,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,23899727)
	e1:SetCondition(c23899727.condition)
	e1:SetTarget(c23899727.target)
	e1:SetOperation(c23899727.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断该卡是否因破坏而送去墓地且之前在场上
function c23899727.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果作用：过滤满足条件的「水精鳞」怪兽（不包括自身）且可特殊召唤
function c23899727.filter(c,e,tp)
	return c:IsSetCard(0x74) and not c:IsCode(23899727) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件（场上存在空位且卡组存在符合条件的怪兽）
function c23899727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c23899727.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，提示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c23899727.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从卡组选择符合条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c23899727.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
