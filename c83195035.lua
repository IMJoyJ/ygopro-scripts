--竜嵐還帰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
function c83195035.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,83195035+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c83195035.target)
	e1:SetOperation(c83195035.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且可以特殊召唤的怪兽
function c83195035.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测
function c83195035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c83195035.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只满足条件的自己或对方的怪兽
		and Duel.IsExistingTarget(c83195035.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的自己或对方的怪兽作为对象
	local g=Duel.SelectTarget(tp,c83195035.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c83195035.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(83195035,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c83195035.thcon)
		e1:SetOperation(c83195035.thop)
		-- 注册该全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍带有标记，若标记不符则重置该延迟效果
function c83195035.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(83195035)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段将特殊召唤的怪兽送回持有者手卡的操作函数
function c83195035.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽因效果送回持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
