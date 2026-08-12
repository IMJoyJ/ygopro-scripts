--CNo.1 ゲート・オブ・カオス・ヌメロン－シニューニャ
-- 效果：
-- 2星怪兽×4
-- 这张卡也能在自己场上的「No.1 源数之门-壹」上面重叠来超量召唤。
-- ①：这张卡超量召唤成功的场合发动。场上的怪兽全部除外。
-- ②：这张卡被除外的场合，下次的自己准备阶段才能发动。除外的这张卡特殊召唤。自己的场地区域有「源数网络」存在的场合，再给与对方为除外的自己·对方的超量怪兽的攻击力合计数值的伤害。
function c79747096.initial_effect(c)
	-- 注册卡片脚本中关联的卡片密码（「No.1 源数之门-壹」与「源数网络」）。
	aux.AddCodeList(c,15232745,41418852)
	aux.AddXyzProcedure(c,nil,2,4,c79747096.ovfilter,aux.Stringid(79747096,0))  --"是否在「No.1 源数之门-壹」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的场合发动。场上的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79747096,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c79747096.rmcon)
	e1:SetTarget(c79747096.rmtg)
	e1:SetOperation(c79747096.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c79747096.regop)
	c:RegisterEffect(e2)
	-- 下次的自己准备阶段才能发动。除外的这张卡特殊召唤。自己的场地区域有「源数网络」存在的场合，再给与对方为除外的自己·对方的超量怪兽的攻击力合计数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79747096,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1)
	e3:SetCondition(c79747096.spcon)
	e3:SetTarget(c79747096.sptg)
	e3:SetOperation(c79747096.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 设定该怪兽的「No.」数值为1。
aux.xyz_number[79747096]=1
-- 过滤用于重叠超量召唤的怪兽，需为表侧表示的「No.1 源数之门-壹」。
function c79747096.ovfilter(c)
	return c:IsFaceup() and c:IsCode(15232745)
end
-- 效果①的发动条件：这张卡超量召唤成功。
function c79747096.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的发动准备：获取场上所有可以被除外的怪兽，并设置除外操作信息。
function c79747096.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有可以被除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置除外操作信息，包含目标怪兽组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的处理：将场上所有可以被除外的怪兽全部除外。
function c79747096.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有可以被除外的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果将目标怪兽组表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的除外时注册操作：记录除外时的回合和阶段，并为自身注册标记。
function c79747096.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断被除外时是否正好是自己的准备阶段。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将当前回合数记录在效果标签中，用于防止在被除外的当个准备阶段直接发动效果。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(79747096,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(79747096,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 效果②的发动条件：当前是自己的准备阶段，且自身带有除外标记，且不是在被除外的同一个准备阶段。
function c79747096.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己，且自身是否存在除外时注册的标记。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(79747096)>0
		-- 确保当前回合数不等于被除外时的回合数（即必须是“下次的”准备阶段）。
		and e:GetLabelObject():GetLabel()~=Duel.GetTurnCount()
end
-- 效果②的发动准备：检查自身是否能特殊召唤，并设置特殊召唤操作信息。
function c79747096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息，目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤用于计算伤害的怪兽：表侧表示、超量怪兽且攻击力大于0。
function c79747096.damfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetAttack()>0
end
-- 效果②的处理：特殊召唤自身，若场上有「源数网络」且存在除外的超量怪兽，则给与对方伤害。
function c79747096.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果关联，并成功将自身表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己的场地区域是否存在「源数网络」。
		and Duel.IsEnvironment(41418852,tp,LOCATION_FZONE)
		-- 检查除外区是否存在至少1只满足条件的超量怪兽。
		and Duel.IsExistingMatchingCard(c79747096.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) then
		-- 中断当前效果处理，使特殊召唤与之后的伤害处理不视为同时进行。
		Duel.BreakEffect()
		-- 获取除外区所有满足条件的超量怪兽。
		local g=Duel.GetMatchingGroup(c79747096.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		local dam=g:GetSum(Card.GetAttack)
		-- 给与对方玩家相当于这些超量怪兽攻击力合计数值的效果伤害。
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
