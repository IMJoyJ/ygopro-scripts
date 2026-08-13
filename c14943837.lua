--デブリ・ドラゴン
-- 效果：
-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用，其他的同调素材怪兽必须全部是4星以外的怪兽。
-- ①：这张卡召唤成功时，以自己墓地1只攻击力500以下的怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c14943837.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是龙族怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c14943837.synlimit)
	c:RegisterEffect(e1)
	-- 其他的同调素材怪兽必须全部是4星以外的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTarget(c14943837.synlimit2)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地1只攻击力500以下的怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14943837,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c14943837.sumtg)
	e3:SetOperation(c14943837.sumop)
	c:RegisterEffect(e3)
end
-- 同调素材限制判定：c 为本次同调召唤要召唤的怪兽；若该怪兽不是龙族则返回 true，使星骸龙不能作为素材，以实现只能用于龙族同调召唤。
function c14943837.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_DRAGON)
end
-- 调整素材限制判定：对其他同调素材怪兽进行判定，若是4星则返回 false 禁止作为素材；非4星（4星以外）才允许使用。
function c14943837.synlimit2(e,c)
	return not c:IsLevel(4)
end
-- 墓地对象筛选函数：怪兽必须攻击力500以下，并且能够被当前效果特殊召唤为表侧攻击表示。
function c14943837.filter2(c,e,sp)
	return c:IsAttackBelow(500) and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEUP_ATTACK)
end
-- 取对象/发动条件处理：检查连锁选择的卡是己方墓地且满足 filter2；发动确认时判断主怪兽区有空位且墓地存在符合条件的对象。
function c14943837.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14943837.filter2(chkc,e,tp) end
	-- 发动条件之一：自己主怪兽区必须存在空格，否则无法把怪兽特殊召唤出来。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足 filter2 且可作为对象的怪兽。
		and Duel.IsExistingTarget(c14943837.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于接下来的卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的满足条件怪兽中选择1张，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c14943837.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记当前连锁的操作信息：本效果将特殊召唤1张卡，供相关效果检测连锁内容使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得对象 tc；若 tc 仍与效果关联且可表侧攻击表示特殊召唤，则用 SpecialSummonStep 将其特殊召唤；随后给 tc 附加 EFFECT_DISABLE 与 EFFECT_DISABLE_EFFECT 使其效果无效化，并在标准重置时机清除；最后调用 SpecialSummonComplete 完成特殊召唤。
function c14943837.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中登记的第一张对象卡，即发动效果时选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与本次效果有关联（没有因离场等原因失联），并且能以表侧攻击表示特殊召唤；通过后执行特殊召唤步骤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 结束本次特殊召唤流程，向系统提交 SpecialSummonStep 累积的特殊召唤，完成整个特殊召唤处理。
	Duel.SpecialSummonComplete()
end
