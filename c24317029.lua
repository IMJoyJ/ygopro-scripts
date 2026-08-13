--墓守の偵察者
-- 效果：
-- 反转：从自己的卡组中特殊召唤1张攻击力1500以下名称中带有「守墓」的怪兽卡。
function c24317029.initial_effect(c)
	-- 反转：从自己的卡组中特殊召唤1张攻击力1500以下名称中带有「守墓」的怪兽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24317029,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c24317029.target)
	e1:SetOperation(c24317029.operation)
	c:RegisterEffect(e1)
end
-- 反转效果发动时的处理：先判定是否满足发动条件（chk==0时直接允许发动），并登记本次连锁将进行特殊召唤的操作信息。
function c24317029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果处理时预定从卡组特殊召唤1只怪兽的操作信息，供星尘龙、王家长眠之谷等效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 筛选满足条件的卡：攻击力在1500以下、卡名包含「守墓」字段、并且能够被当前效果特殊召唤的怪兽。
function c24317029.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理阶段：先确认己方主要怪兽区有空位，然后提示玩家选择卡组中符合条件的怪兽，最后将其特殊召唤。
function c24317029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否还有可用的空格；若没有空格则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选出1张符合过滤条件且可以特殊召唤的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c24317029.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到己方场上，不进行召唤条件检查、也不进行苏生限制检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
