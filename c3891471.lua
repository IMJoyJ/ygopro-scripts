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
-- 过滤函数：判断怪兽为念动力族，且能够由当前效果以表侧攻击表示特殊召唤。
function c3891471.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时点检查：若指定对象则必须是己方墓地中满足特招条件的念动力族；若无对象则确认主怪兽区有空位且墓地存在至少1只可被选为对象的念动力族怪兽。
function c3891471.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3891471.filter(chkc,e,tp) end
	-- 检查己方主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足特招条件且能成为效果对象的念动力族怪兽。
		and Duel.IsExistingTarget(c3891471.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只符合条件的念动力族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c3891471.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：该效果包含特殊召唤，对象为所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若此卡和对象仍与效果关联且对象仍是念动力族，则记录其等级，将对象以表侧攻击表示特殊召唤，成功后建立此卡与对象的联系并保存等级标记，最后完成特殊召唤处理。
function c3891471.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁所选择的第1个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) then
		local lv=tc:GetLevel()
		-- 使用分步特殊召唤处理，将目标怪兽以表侧攻击表示特殊召唤到己方场上。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			c:SetCardTarget(tc)
			c:RegisterFlagEffect(3891471,RESET_EVENT+0x17a0000,0,1,lv)
		end
		-- 完成整个特殊召唤处理，触发特殊召唤成功的时点。
		Duel.SpecialSummonComplete()
	end
end
-- 离场时破坏对象怪兽的处理：当此卡离开场上时，取出其效果对象，若对象仍在怪兽区则将其破坏。
function c3891471.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏那只被特殊召唤的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 离场条件判断：取得此卡的效果对象，若当前离场事件中包含该对象怪兽，则条件成立。
function c3891471.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽离场时破坏此卡的处理：当被特殊召唤的怪兽离开场上时，直接破坏这张卡。
function c3891471.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏“念力调整”自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 伤害效果的发动条件与信息设置：若此卡带有记录特殊召唤怪兽等级的标志，则将伤害对象设为自身，伤害数值设为等级×400，并设置操作信息为伤害效果。
function c3891471.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3891471)~=0 end
	-- 设置当前连锁的伤害对象玩家为此卡的控制者。
	Duel.SetTargetPlayer(tp)
	local lv=e:GetHandler():GetFlagEffectLabel(3891471)
	-- 设置当前连锁的伤害数值参数为记录等级乘以400。
	Duel.SetTargetParam(lv*400)
	-- 设置操作信息，标明该效果将造成伤害以及伤害对象与数值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,lv*400)
end
-- 伤害处理：从连锁信息取得对象玩家和伤害值，并对该玩家造成效果伤害。
function c3891471.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成对应数值的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
