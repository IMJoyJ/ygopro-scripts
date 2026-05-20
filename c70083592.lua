--縫合蘇生
-- 效果：
-- 「缝合苏生」在1回合只能发动1张。
-- ①：以自己墓地1只「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c70083592.initial_effect(c)
	-- 「缝合苏生」在1回合只能发动1张。①：以自己墓地1只「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,70083592+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c70083592.target)
	e1:SetOperation(c70083592.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中可以特殊召唤的「毛绒动物」或「魔玩具」怪兽
function c70083592.filter(c,e,tp)
	return c:IsSetCard(0xa9,0xad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查合法对象、选择对象并设置操作信息）
function c70083592.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c70083592.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c70083592.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70083592.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（特殊召唤目标怪兽并将其效果无效化）
function c70083592.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果条件，则将其以表侧表示特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
