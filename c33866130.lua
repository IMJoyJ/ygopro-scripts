--ナチュル・クリフ
-- 效果：
-- 这张卡从场上送去墓地时，可以从自己卡组把1只4星以下的名字带有「自然」的怪兽在自己场上表侧攻击表示特殊召唤。
function c33866130.initial_effect(c)
	-- 这张卡从场上送去墓地时，可以从自己卡组把1只4星以下的名字带有「自然」的怪兽在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33866130,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c33866130.spcon)
	e1:SetTarget(c33866130.sptg)
	e1:SetOperation(c33866130.spop)
	c:RegisterEffect(e1)
end
-- 判断触发条件：该卡（效果持有者）在被送去墓地之前是否位于场上。
function c33866130.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可选怪兽的筛选条件：卡名含有「自然」、等级4以下、且能够以表侧攻击表示特殊召唤。
function c33866130.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 选择发动目标的阶段：确认自己主要怪兽区有空位，且卡组中存在满足筛选条件的怪兽，才能发动。
function c33866130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「自然」怪兽。
		and Duel.IsExistingMatchingCard(c33866130.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次效果操作：将进行1只怪兽的特殊召唤，来源为卡组，持有者为发动者。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：结算时选择并特殊召唤符合条件的怪兽。
function c33866130.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认主要怪兽区有空位，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家从卡组选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足条件的「自然」怪兽。
	local g=Duel.SelectMatchingCard(tp,c33866130.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
