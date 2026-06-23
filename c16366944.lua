--月光蝶
-- 效果：
-- 这张卡从场上送去墓地时，可以从卡组把1只4星以下的名字带有「幻蝶刺客」的怪兽特殊召唤。
function c16366944.initial_effect(c)
	-- 诱发选发效果，满足条件时可以发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16366944,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c16366944.condition)
	e1:SetTarget(c16366944.target)
	e1:SetOperation(c16366944.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时，确认此卡之前在场上
function c16366944.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足等级4以下、幻蝶刺客系列且可特殊召唤的怪兽
function c16366944.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x6a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，包括场上存在空位和卡组存在符合条件的怪兽
function c16366944.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c16366944.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段，执行特殊召唤操作
function c16366944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上无空怪兽区域则取消效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c16366944.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
