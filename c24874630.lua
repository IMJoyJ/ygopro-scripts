--デビルズ・サンクチュアリ
-- 效果：
-- ①：在自己场上把1只「金属恶魔衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。这衍生物不能攻击，这衍生物的战斗发生的对控制者的战斗伤害由对方代受。这衍生物的控制者在每次自己准备阶段支付1000基本分。或者不支付基本分让这衍生物破坏。
function c24874630.initial_effect(c)
	-- ①：在自己场上把1只「金属恶魔衍生物」（恶魔族·暗·1星·攻/守0）特殊召唤。这衍生物不能攻击，这衍生物的战斗发生的对控制者的战斗伤害由对方代受。这衍生物的控制者在每次自己准备阶段支付1000基本分。或者不支付基本分让这衍生物破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24874630.target)
	e1:SetOperation(c24874630.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足特殊召唤金属恶魔衍生物的条件
function c24874630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤指定的金属恶魔衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,24874631,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息，表明将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，表明将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 检查是否满足特殊召唤金属恶魔衍生物的条件
function c24874630.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断玩家是否可以特殊召唤指定的金属恶魔衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,24874631,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建一个编号为24874631的金属恶魔衍生物
	local token=Duel.CreateToken(tp,24874631)
	-- 将创建的衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这衍生物不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	-- 这衍生物的战斗发生的对控制者的战斗伤害由对方代受
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
-- 判断是否轮到该玩家的准备阶段
function c24874630.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为该衍生物的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 处理准备阶段的支付或破坏效果
function c24874630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否能支付1000基本分并选择是否支付
	if Duel.CheckLPCost(tp,1000) and Duel.SelectYesNo(tp,aux.Stringid(24874630,0)) then  --"是否要支付1000基本分维持「金属恶魔衍生物」？"
		-- 支付1000基本分
		Duel.PayLPCost(tp,1000)
	else
		-- 因未支付基本分而破坏该衍生物
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
