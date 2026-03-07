--スレイブ・エイプ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只名字带有「剑斗兽」的4星以下怪兽在自己场上特殊召唤。
function c3030892.initial_effect(c)
	-- 诱发选发效果，当此卡被战斗破坏送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3030892,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c3030892.condition)
	e1:SetTarget(c3030892.target)
	e1:SetOperation(c3030892.operation)
	c:RegisterEffect(e1)
end
-- 效果适用的条件：此卡在墓地且因战斗破坏
function c3030892.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：等级4以下、剑斗兽卡组、可特殊召唤
function c3030892.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断：场上存在空位且卡组存在符合条件的怪兽
function c3030892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c3030892.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理流程：若场上存在空位则提示选择并特殊召唤符合条件的怪兽
function c3030892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g = Duel.SelectMatchingCard(tp,c3030892.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
