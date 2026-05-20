--Sin Cross
-- 效果：
-- ①：以自己墓地1只「罪」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
function c81384993.initial_effect(c)
	-- ①：以自己墓地1只「罪」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81384993.target)
	e1:SetOperation(c81384993.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤的「罪」怪兽
function c81384993.filter(c,e,tp)
	return c:IsSetCard(0x23) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的发动目标确认与合法性检测
function c81384993.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c81384993.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「罪」怪兽
		and Duel.IsExistingTarget(c81384993.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「罪」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81384993.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理逻辑（特殊召唤、无效化效果、注册结束阶段除外的效果）
function c81384993.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则无视召唤条件将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(81384993,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c81384993.rmcon1)
		e3:SetOperation(c81384993.rmop1)
		-- 注册在结束阶段将该怪兽除外的全局效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 检查特殊召唤的怪兽是否仍在场且标记未改变，以决定是否在结束阶段除外
function c81384993.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(81384993)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外该怪兽的具体操作
function c81384993.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽表侧表示除外
	Duel.Remove(e:GetLabelObject(),POS_FACEUP,REASON_EFFECT)
end
