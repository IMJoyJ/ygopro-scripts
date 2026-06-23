--ロードポイズン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己墓地里特殊召唤1只「毒根王」以外的植物族怪兽上场。
function c40320754.initial_effect(c)
	-- 诱发效果：这张卡被战斗破坏送去墓地时，从自己墓地里特殊召唤1只「毒根王」以外的植物族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40320754,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c40320754.condition)
	e1:SetTarget(c40320754.target)
	e1:SetOperation(c40320754.operation)
	c:RegisterEffect(e1)
end
-- 效果适用条件：这张卡在墓地且因战斗破坏而离开场上的场合。
function c40320754.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选满足条件的墓地怪兽：必须是植物族且不是毒根王的怪兽，且可以特殊召唤。
function c40320754.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and not c:IsCode(40320754) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择特殊召唤目标：从自己墓地选择1只符合条件的植物族怪兽。
function c40320754.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40320754.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为特殊召唤目标。
	local g=Duel.SelectTarget(tp,c40320754.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将符合条件的怪兽特殊召唤到场上。
function c40320754.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的怪兽作为处理对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
