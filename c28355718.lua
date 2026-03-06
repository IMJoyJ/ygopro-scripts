--D-HERO ダブルガイ
-- 效果：
-- 这张卡不能特殊召唤。这张卡在同1次的战斗阶段中可以作2次攻击。这张卡被破坏送去墓地的场合，下次的自己回合的准备阶段时，可以在自己场上把2只「双身人衍生物」（战士族·暗·4星·攻/守1000）特殊召唤。
function c28355718.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡被破坏送去墓地的场合，下次的自己回合的准备阶段时，可以在自己场上把2只「双身人衍生物」（战士族·暗·4星·攻/守1000）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c28355718.regop)
	c:RegisterEffect(e3)
end
-- 当此卡因破坏而进入墓地时，将一个诱发效果注册到场上，该效果在下次自己的准备阶段时发动，将2只双身人衍生物特殊召唤到场上。
function c28355718.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 注册一个在准备阶段发动的诱发效果，用于特殊召唤双身人衍生物。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(28355718,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(c28355718.spcon)
		e1:SetTarget(c28355718.sptg)
		e1:SetOperation(c28355718.spop)
		-- 若当前回合玩家是该卡的控制者，则设置效果在2个回合后重置。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		c:RegisterEffect(e1)
	end
end
-- 判断是否为当前回合玩家的准备阶段。
function c28355718.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 判断是否满足特殊召唤双身人衍生物的条件，包括未被青眼精灵龙效果影响、场上至少有2个空位、可以特殊召唤双身人衍生物。
function c28355718.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断场上是否有至少2个空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断是否可以特殊召唤双身人衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28355719,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 设置操作信息，表示将要特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将要特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 执行特殊召唤双身人衍生物的操作，包括检查是否被青眼精灵龙效果影响、是否有足够空位、是否可以特殊召唤。
function c28355718.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若场上空位不足2个，则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 若无法特殊召唤双身人衍生物，则不执行特殊召唤。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28355719,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
	for i=1,2 do
		-- 创建一只双身人衍生物。
		local token=Duel.CreateToken(tp,28355719)
		-- 将一只双身人衍生物特殊召唤到场上。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成所有特殊召唤步骤。
	Duel.SpecialSummonComplete()
end
