--ベアルクティ・スライダー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只「北极天熊」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。这张卡的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
function c53865474.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,53865474+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53865474.target)
	e1:SetOperation(c53865474.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「北极天熊」怪兽（在墓地或除外区且可特殊召唤）
function c53865474.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x163) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件（场上存在符合条件的怪兽）
function c53865474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c53865474.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地或除外区存在符合条件的怪兽
		and Duel.IsExistingTarget(c53865474.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c53865474.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动后的操作
function c53865474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤的怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(53865474,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 在结束阶段时破坏该怪兽
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c53865474.descon)
		e2:SetOperation(c53865474.desop)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e2,tp)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后直到回合结束时自己若非持有等级的怪兽则不能特殊召唤
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c53865474.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能特殊召唤的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断目标怪兽是否仍处于场上
function c53865474.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(53865474)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏目标怪兽
function c53865474.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 限制特殊召唤的怪兽必须具有等级
function c53865474.splimit(e,c)
	return c:IsLevel(0)
end
