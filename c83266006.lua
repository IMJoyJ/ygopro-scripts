--逢華妖麗譚－魔妖語
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，以自己场上1只不死族同调怪兽为对象才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选和作为对象的怪兽相同属性的1只不死族怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。这张卡的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
function c83266006.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，以自己场上1只不死族同调怪兽为对象才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选和作为对象的怪兽相同属性的1只不死族怪兽特殊召唤。
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
-- 检查发动条件：当前所处阶段是否为自己或对方的主要阶段1或主要阶段2
function c83266006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前决斗阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己场上可作为对象的怪兽：须为表侧表示的不死族同调怪兽，且自己墓地或除外区中存在至少1只与其属性相同并可特召的不死族怪兽
function c83266006.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE)
		-- 检查自己墓地或除外区中是否存在至少1只与对象怪兽属性相同的可特殊召唤不死族怪兽
		and Duel.IsExistingMatchingCard(c83266006.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c:GetAttribute())
end
-- 过滤墓地或除外区中可被特殊召唤的怪兽：位于墓地或表侧除外状态、种族为不死族、属性与对象怪兽一致且能够被特殊召唤
function c83266006.spfilter(c,e,tp,att)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_ZOMBIE) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：确认自己怪兽区有空位且存在符合条件可成为对象的不死族同调怪兽
function c83266006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83266006.cfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否还有至少1个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己怪兽区是否存在至少1只满足条件的表侧表示不死族同调怪兽可成为对象
		and Duel.IsExistingTarget(c83266006.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向发动玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从自己怪兽区选择1只不死族同调怪兽作为本次连锁的对象
	Duel.SelectTarget(tp,c83266006.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记本次连锁包含从自己墓地或除外区特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 执行①效果处理：若对象怪兽仍关联且有空位，从自己墓地·除外区选1只同属性不死族怪兽特殊召唤并为其附加结束阶段除外的延时处理效果；卡的发动后，施加直到回合结束时不能特殊召唤不死族以外怪兽的限制
function c83266006.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的自己场上不死族同调怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与效果关联且为表侧表示，同时自己主要怪兽区仍有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local att=tc:GetAttribute()
		-- 向发动玩家发送选择要特殊召唤的卡片提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让发动玩家从自己墓地·除外区中（排除受王家长眠之谷影响的墓地卡）选择1只与对象怪兽属性相同的不死族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c83266006.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,att)
		-- 若选出了怪兽且成功以表侧表示将其特殊召唤到自己场上
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
			-- 为自己注册在结束阶段将特召怪兽除外的延时处理效果
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
		-- 为自己注册持续到回合结束时的不死族特殊召唤限制效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 检查结束阶段除外效果的触发条件：确认目标怪兽仍持有对应标记（仍留在场上未离场重置），否则重置该延时效果
function c83266006.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(83266006)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行结束阶段除外处理：将记录的目标怪兽以表侧表示通过效果除外
function c83266006.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果将目标怪兽表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 特殊召唤种族限制过滤函数：禁止特殊召唤种族不为不死族的怪兽
function c83266006.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
