--デビルズ・サンクチュアリ
-- 效果：
-- ①：在自己场上把1只「金属恶魔衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。这衍生物不能攻击，这衍生物的战斗发生的对控制者的战斗伤害由对方代受。这衍生物的控制者在每次自己准备阶段支付1000基本分。或者不支付基本分让这衍生物破坏。
function c24874630.initial_effect(c)
	-- ①：在自己场上把1只「金属恶魔衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24874630.target)
	e1:SetOperation(c24874630.activate)
	c:RegisterEffect(e1)
end
-- 发动时判定：满足自己主要怪兽区有空位且自己能特殊召唤该衍生物时，效果才可发动。
function c24874630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否特殊召唤「金属恶魔衍生物」（恶魔族·暗·1星·攻/守0的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,24874631,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次处理将生成1只衍生物，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理将进行1次特殊召唤，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时再次确认条件，满足则执行特殊召唤并为衍生物附加后续效果。
function c24874630.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时判定：若自己场上没有可用主要怪兽区则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 效果处理时判定：若自己已不能特殊召唤该衍生物则中止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,24874631,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建1只「金属恶魔衍生物」的衍生物实体。
	local token=Duel.CreateToken(tp,24874631)
	-- 将生成的衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	-- 这衍生物的战斗发生的对控制者的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2,true)
	-- 这衍生物的控制者在每次自己准备阶段支付1000基本分。或者不支付基本分让这衍生物破坏。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c24874630.descon)
	e3:SetOperation(c24874630.desop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e3,true)
end
-- 准备阶段维持效果的触发条件：仅在衍生物控制者的准备阶段才进行后续处理。
function c24874630.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为衍生物的控制者，确保只在控制者的准备阶段触发。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段处理：询问控制者是否支付1000基本分维持衍生物；支付则扣血，不支付则破坏衍生物。
function c24874630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定控制者能否支付1000基本分，并让控制者选择是否支付。
	if Duel.CheckLPCost(tp,1000) and Duel.SelectYesNo(tp,aux.Stringid(24874630,0)) then  --"是否要支付1000基本分维持「金属恶魔衍生物」？"
		-- 控制者支付1000基本分作为维持衍生物的费用。
		Duel.PayLPCost(tp,1000)
	else
		-- 控制者不支付基本分时，将衍生物以代价形式破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
