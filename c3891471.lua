--サイコ・チューン
-- 效果：
-- 选择自己墓地存在的1只念动力族怪兽，攻击表示特殊召唤。这个效果特殊召唤的怪兽当作调整使用。这张卡不在场上存在时，那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。这张卡被送去墓地时，自己受到这张卡的效果特殊召唤的怪兽等级×400的数值的伤害。
function c3891471.initial_effect(c)
	-- 选择自己墓地存在的1只念动力族怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3891471.target)
	e1:SetOperation(c3891471.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c3891471.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c3891471.descon2)
	e3:SetOperation(c3891471.desop2)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地时，自己受到这张卡的效果特殊召唤的怪兽等级×400的数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3891471,0))  --"伤害"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c3891471.damtg)
	e4:SetOperation(c3891471.damop)
	c:RegisterEffect(e4)
	-- 这个效果特殊召唤的怪兽当作调整使用。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(TYPE_TUNER)
	c:RegisterEffect(e5)
end
-- 检索满足条件的念动力族怪兽，用于特殊召唤。
function c3891471.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置选择目标的条件为己方墓地的念动力族怪兽。
function c3891471.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3891471.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地是否存在满足条件的念动力族怪兽。
		and Duel.IsExistingTarget(c3891471.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只念动力族怪兽作为特殊召唤目标。
	local g=Duel.SelectTarget(tp,c3891471.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上。
function c3891471.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) then
		local lv=tc:GetLevel()
		-- 尝试将目标怪兽特殊召唤到场上。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			c:SetCardTarget(tc)
			c:RegisterFlagEffect(3891471,RESET_EVENT+0x17a0000,0,1,lv)
		end
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 当卡片离开场时，破坏目标怪兽。
function c3891471.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断目标怪兽是否从场上离开。
function c3891471.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当目标怪兽离开场时，破坏此卡。
function c3891471.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 设置伤害效果的目标玩家和伤害值。
function c3891471.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3891471)~=0 end
	-- 设置伤害效果的目标玩家。
	Duel.SetTargetPlayer(tp)
	local lv=e:GetHandler():GetFlagEffectLabel(3891471)
	-- 设置伤害值为怪兽等级乘以400。
	Duel.SetTargetParam(lv*400)
	-- 设置伤害效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,lv*400)
end
-- 执行伤害效果，对目标玩家造成伤害。
function c3891471.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
