--機塊リユース
-- 效果：
-- ①：以自己墓地1只「机块」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
function c30996652.initial_effect(c)
	-- ①：以自己墓地1只「机块」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c30996652.target)
	e1:SetOperation(c30996652.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是「机块」字段的怪兽，并且可以被当前效果以表侧表示特殊召唤。
function c30996652.filter(c,e,tp)
	return c:IsSetCard(0x14b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 目标选择处理：发动时只能选择自己墓地1只满足条件的「机块」怪兽作为对象，且我方主要怪兽区需要有可用空格。
function c30996652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30996652.filter(chkc,e,tp) end
	-- 发动合法性检查：我方主要怪兽区必须存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己墓地是否存在至少1只满足条件的「机块」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c30996652.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示信息“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「机块」怪兽作为效果对象，并自动与当前效果建立关联。
	local g=Duel.SelectTarget(tp,c30996652.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的特殊召唤操作信息，以便其他卡检测该效果将进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，并为其附加“离场时回到持有者卡组最下面”的永续效果。
function c30996652.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则将其以表侧表示特殊召唤到自己场上；仅在特殊召唤成功时才继续附加离场回卡组的效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合回到持有者卡组最下面。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
	end
end
