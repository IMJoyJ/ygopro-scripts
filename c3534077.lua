--熱血獣士ウルフバーク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己墓地1只兽战士族·炎属性·4星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c3534077.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己墓地1只兽战士族·炎属性·4星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3534077,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3534077)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3534077.sptg)
	e1:SetOperation(c3534077.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：选择自己墓地1只兽战士族·炎属性·4星怪兽，且该怪兽可以被特殊召唤（表侧守备表示）。
function c3534077.filter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择处理：确认对象为墓地中符合条件的兽战士族·炎属性·4星怪兽；发动条件为存在可特殊召唤的合适对象且自己主要怪兽区有空位。
function c3534077.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3534077.filter(chkc,e,tp) end
	-- 发动条件检查（chk==0）：自己墓地存在至少1张满足filter条件的兽战士族·炎属性·4星怪兽。
	if chk==0 then return Duel.IsExistingTarget(c3534077.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时自己的主要怪兽区有至少1个可使用空位，供特殊召唤的怪兽放置。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向操作玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张符合条件的兽战士族·炎属性·4星怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3534077.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：本效果将进行1只怪兽的特殊召唤（对象为g），用于时点检测和对方应对。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽守备表示特殊召唤，并对其适用效果无效化处理，最后完成特殊召唤。
function c3534077.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关（未被移离等），然后将其以表侧守备表示特殊召唤（作为连续特殊召唤的一步）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
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
	-- 完成所有特殊召唤步骤，正式处理特殊召唤成功。
	Duel.SpecialSummonComplete()
end
