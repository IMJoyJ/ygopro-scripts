--逢華妖麗譚－魔妖語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，以自己场上1只不死族同调怪兽为对象才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选和作为对象的怪兽相同属性的1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c83266006.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，以自己场上1只不死族同调怪兽为对象才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选和作为对象的怪兽相同属性的1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,83266006+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c83266006.condition)
	e1:SetTarget(c83266006.target)
	e1:SetOperation(c83266006.activate)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为自己或对方的主要阶段。
function c83266006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己场上表侧表示的不死族同调怪兽，且墓地或除外区存在相同属性、可特殊召唤的不死族怪兽。
function c83266006.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE)
		-- 检查自己墓地或除外区是否存在1只与该怪兽相同属性且满足特殊召唤条件的不死族怪兽。
		and Duel.IsExistingMatchingCard(c83266006.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c:GetAttribute())
end
-- 过滤自己墓地（或除外区表侧表示）的、与对象怪兽相同属性且可以特殊召唤的不死族怪兽。
function c83266006.spfilter(c,e,tp,att)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_ZOMBIE) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与操作信息设置。
function c83266006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83266006.cfilter(chkc) end
	-- 判定是否满足发动条件：自己场上有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上存在满足条件的不死族同调怪兽作为对象。
		and Duel.IsExistingTarget(c83266006.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的不死族同调怪兽作为对象。
	Duel.SelectTarget(tp,c83266006.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含从墓地或除外区特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理函数：特殊召唤与对象怪兽相同属性的不死族怪兽，并适用后续的除外和特殊召唤限制效果。
function c83266006.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍在该效果对应的连锁中、是否表侧表示，且自己场上是否有可用的怪兽区域空格。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local att=tc:GetAttribute()
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地或除外区选择1只与对象怪兽相同属性的不死族怪兽（受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c83266006.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,att)
		-- 若成功选择怪兽，则将其在自己场上表侧表示特殊召唤。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local tc=g:GetFirst()
			tc:RegisterFlagEffect(83266006,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 这个效果特殊召唤的怪兽在结束阶段除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(c83266006.rmcon)
			e1:SetOperation(c83266006.rmop)
			-- 全局注册该延迟效果，用于在结束阶段将该怪兽除外。
			Duel.RegisterEffect(e1,tp)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(c83266006.splimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 给玩家注册该特殊召唤限制效果，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判定结束阶段除外效果的触发条件：被特殊召唤的怪兽仍带有对应的标记。
function c83266006.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(83266006)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行结束阶段除外的操作。
function c83266006.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该怪兽表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 限制只能特殊召唤不死族怪兽（不能特殊召唤非不死族怪兽）。
function c83266006.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
