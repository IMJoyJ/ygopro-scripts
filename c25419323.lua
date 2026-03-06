--ダイノルフィア・シェル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方战斗阶段开始时，把基本分支付一半才能发动。在自己场上把1只「恐啡肽狂龙衍生物」（恐龙族·暗·10星·攻0/守3000）特殊召唤。这个回合，只要这个效果特殊召唤的衍生物在自己场上存在，对方不能选择其他怪兽作为攻击对象。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c25419323.initial_effect(c)
	-- ①：对方战斗阶段开始时，把基本分支付一半才能发动。在自己场上把1只「恐啡肽狂龙衍生物」（恐龙族·暗·10星·攻0/守3000）特殊召唤。这个回合，只要这个效果特殊召唤的衍生物在自己场上存在，对方不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCountLimit(1,25419323+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25419323.condition)
	e1:SetCost(c25419323.cost)
	e1:SetTarget(c25419323.target)
	e1:SetOperation(c25419323.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c25419323.damcon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c25419323.damop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：战斗阶段开始且为对方回合
function c25419323.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 战斗阶段开始且为对方回合
	return Duel.GetCurrentPhase()==PHASE_BATTLE_START and Duel.GetTurnPlayer()==1-tp
end
-- 支付一半基本分的费用
function c25419323.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 效果发动时点：特殊召唤衍生物的条件检查
function c25419323.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 场上怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25419324,0,TYPES_TOKEN_MONSTER,0,3000,10,RACE_DINOSAUR,ATTRIBUTE_DARK) end
	-- 设置效果处理信息：召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：特殊召唤衍生物
function c25419323.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 场上怪兽区域无空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 无法特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,25419324,0,TYPES_TOKEN_MONSTER,0,3000,10,RACE_DINOSAUR,ATTRIBUTE_DARK) then return end
	-- 创建恐啡肽狂龙衍生物
	local token=Duel.CreateToken(tp,25419324)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 使对方不能选择其他怪兽作为攻击对象的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c25419323.atklimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	token:RegisterEffect(e1)
end
-- 限制对方攻击目标的条件：不能攻击此衍生物
function c25419323.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 效果发动条件：基本分≤2000且即将受到战斗伤害
function c25419323.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 基本分≤2000且即将受到战斗伤害
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- 效果处理：使战斗伤害变为0
function c25419323.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己受到的战斗伤害变为0的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册战斗伤害减免效果
	Duel.RegisterEffect(e1,tp)
end
