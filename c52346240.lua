--ロックキャット
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只1星的兽族怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c52346240.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地存在的1只1星的兽族怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52346240,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c52346240.sptg)
	e1:SetOperation(c52346240.spop)
	c:RegisterEffect(e1)
end
-- 筛选满足等级1、兽族且能够以表侧守备表示特殊召唤的墓地怪兽。
function c52346240.filter(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件和取对象判定：检查墓地是否存在符合条件的对象以及场上是否有空位。
function c52346240.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52346240.filter(chkc,e,tp) end
	-- 发动时确认墓地是否存在符合条件的1星兽族怪兽作为特殊召唤对象。
	if chk==0 then return Duel.IsExistingTarget(c52346240.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时确认自己场上存在可用的主要怪兽区空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示“请选择要特殊召唤的卡”，并进入选卡引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的1星兽族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c52346240.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次效果处理的信息为特殊召唤1只对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：将对象怪兽表侧守备表示特殊召唤，并对其适用效果无效化；最后完成特殊召唤。
function c52346240.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的取对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且仍为兽族，然后以表侧守备表示进行特殊召唤（进入特殊召唤步骤）。
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_BEAST) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
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
	-- 完成特殊召唤的后续处理，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
end
