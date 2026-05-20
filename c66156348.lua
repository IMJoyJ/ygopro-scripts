--竜皇神話
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。对方场上有龙族怪兽存在的场合，再在这个回合让作为对象的怪兽的效果的发动不会被无效化。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只龙族超量怪兽守备表示特殊召唤。
function c66156348.initial_effect(c)
	-- ①：以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。对方场上有龙族怪兽存在的场合，再在这个回合让作为对象的怪兽的效果的发动不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,66156348)
	-- 限制该效果在伤害步骤的伤害计算前才能发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c66156348.target)
	e1:SetOperation(c66156348.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选1只龙族超量怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,66156348)
	-- 把墓地的这张卡除外作为发动效果的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c66156348.sptg)
	e2:SetOperation(c66156348.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的龙族怪兽
function c66156348.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动准备：选择自己场上1只表侧表示的龙族怪兽作为对象
function c66156348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66156348.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c66156348.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的龙族怪兽作为对象
	Duel.SelectTarget(tp,c66156348.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：使对象怪兽攻击力翻倍，若对方场上有龙族怪兽则使其效果发动不被无效
function c66156348.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 检查对方场上是否存在表侧表示的龙族怪兽
		if Duel.IsExistingMatchingCard(c66156348.filter,tp,0,LOCATION_MZONE,1,nil) then
			tc:RegisterFlagEffect(66156348,RESET_EVENT+RESET_TOFIELD+RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
			-- 对方场上有龙族怪兽存在的场合，再在这个回合让作为对象的怪兽的效果的发动不会被无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_INACTIVATE)
			e2:SetReset(RESET_PHASE+PHASE_END)
			e2:SetValue(c66156348.efilter)
			-- 注册全局效果，使该玩家的特定怪兽效果发动不会被无效化
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 过滤不会被无效化的效果：必须是该对象怪兽在怪兽区域发动的效果
function c66156348.efilter(e,ct)
	-- 获取当前处理连锁的发动效果和发动位置
	local te,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	return te:GetHandler():GetFlagEffect(66156348)~=0 and loc==LOCATION_MZONE
end
-- 过滤条件：自己墓地或除外状态的、可以守备表示特殊召唤的龙族超量怪兽
function c66156348.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备：检查怪兽区域空位以及是否存在可特殊召唤的怪兽
function c66156348.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地或除外的卡中是否存在至少1只满足特殊召唤条件的龙族超量怪兽
		and Duel.IsExistingMatchingCard(c66156348.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁信息，表明该效果包含从墓地或除外状态特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的处理：从墓地或除外的怪兽中选择1只龙族超量怪兽守备表示特殊召唤
function c66156348.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地及除外状态中满足特殊召唤条件且不受王家长眠之谷影响的龙族超量怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c66156348.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽以守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
