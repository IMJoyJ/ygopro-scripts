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
	-- ①：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏送去墓地的场合，下次的自己回合的准备阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c28355718.regop)
	c:RegisterEffect(e3)
end
-- 当这张卡被破坏送去墓地时，为其在墓地中注册一个可在下次自己回合准备阶段发动的诱发效果，用于后续特殊召唤衍生物。
function c28355718.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 在自己场上把2只「双身人衍生物」（战士族·暗·4星·攻/守1000）特殊召唤。
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
		-- 判断当前回合玩家是否为这张卡的控制者，从而设置新注册效果的合适重置时机，确保只在“下次自己的回合的准备阶段”可发动。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		c:RegisterEffect(e1)
	end
end
-- spcon作为诱发效果的发动条件，判断当前回合玩家是否为这张卡的控制者，即是否处于自己的准备阶段。
function c28355718.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否等于这张卡的控制者，用于确认当前是己方回合。
	return Duel.GetTurnPlayer()==tp
end
-- 发动时的目标合法性判定：确认没有「青眼精灵龙」的同时特殊召唤限制、自己怪兽区有至少2个空格且玩家能够特殊召唤衍生物，满足才可发动。
function c28355718.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区域是否有超过1个可用空格，确保有足够空位特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查当前玩家能否特殊召唤「双身人衍生物」（战士族·暗·4星·攻/守1000），确认没有特殊召唤禁止等限制。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28355719,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_DARK) end
	-- 将操作信息登记为生成2只衍生物，供连锁处理和依赖操作信息的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 将操作信息登记为特殊召唤2只怪兽，供连锁处理和依赖操作信息的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理时再次确认没有「青眼精灵龙」限制、有足够空位且可特殊召唤衍生物，然后创建并特殊召唤2只衍生物，最后完成特殊召唤。
function c28355718.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理阶段再次检查自己怪兽区是否有至少2个可用空格，若不足则停止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 处理阶段再次确认玩家仍能特殊召唤衍生物，若不能则停止特殊召唤处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28355719,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
	for i=1,2 do
		-- 创建1只「双身人衍生物」衍生物，归属于当前玩家。
		local token=Duel.CreateToken(tp,28355719)
		-- 将该衍生物以正面表示特殊召唤到当前玩家场上，作为多步特殊召唤中的一步。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 结束特殊召唤步骤，使之前逐步特殊召唤的衍生物正式特殊召唤成功。
	Duel.SpecialSummonComplete()
end
