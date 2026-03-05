--マスク・チェンジ
-- 效果：
-- ①：以自己场上1只「英雄」怪兽为对象才能发动。把那只怪兽的属性确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把持有相同属性的1只「假面英雄」怪兽从额外卡组特殊召唤。
function c21143940.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只「英雄」怪兽为对象才能发动。把那只怪兽的属性确认，送去墓地。这个效果让那只怪兽从场上离开的场合，再把持有相同属性的1只「假面英雄」怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c21143940.target)
	e1:SetOperation(c21143940.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「假面英雄」怪兽，包括属性匹配、可以特殊召唤、额外卡组有召唤空间。
function c21143940.tfilter(c,att,e,tp,tc)
	return c:IsSetCard(0xa008) and c:IsAttribute(att)
		-- 检查目标怪兽是否可以特殊召唤且额外卡组有召唤空间。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 检索满足条件的「英雄」怪兽，包括正面表示、属于英雄卡组、额外卡组存在相同属性的假面英雄怪兽。
function c21143940.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x8)
		-- 检查额外卡组是否存在满足条件的假面英雄怪兽。
		and Duel.IsExistingMatchingCard(c21143940.tfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttribute(),e,tp,c)
end
-- 检查目标怪兽是否为正面表示的英雄怪兽且属性匹配。
function c21143940.chkfilter(c,att)
	return c:IsFaceup() and c:IsSetCard(0x8) and (c:GetAttribute()&att)==att
end
-- 效果作用：选择一只自己场上的英雄怪兽作为对象，将其送去墓地，并特殊召唤一只与该怪兽属性相同的假面英雄怪兽。
function c21143940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21143940.chkfilter(chkc,e:GetLabel()) end
	-- 判断是否满足发动条件，即场上是否存在符合条件的英雄怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21143940.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一只符合条件的英雄怪兽作为对象。
	local g=Duel.SelectTarget(tp,c21143940.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:SetLabel(g:GetFirst():GetAttribute())
end
-- 效果作用：将目标怪兽送去墓地，并从额外卡组特殊召唤一只与该怪兽属性相同的假面英雄怪兽。
function c21143940.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local att=tc:GetAttribute()
	-- 将目标怪兽送去墓地。
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要特殊召唤的假面英雄怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择一只与目标怪兽属性相同的假面英雄怪兽。
	local sg=Duel.SelectMatchingCard(tp,c21143940.tfilter,tp,LOCATION_EXTRA,0,1,1,nil,att,e,tp,nil)
	if sg:GetCount()>0 then
		-- 中断当前效果，使后续处理视为不同时处理。
		Duel.BreakEffect()
		-- 将选中的假面英雄怪兽特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,true,POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
