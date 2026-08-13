--ダイノルフィア・シェル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方战斗阶段开始时，把基本分支付一半才能发动。在自己场上把1只「恐啡肽狂龙衍生物」（恐龙族·暗·10星·攻0/守3000）特殊召唤。这个回合，只要这个效果特殊召唤的衍生物在自己场上存在，对方不能选择其他怪兽作为攻击对象。
-- ②：自己基本分是2000以下，自己要受到战斗伤害的伤害计算时，把墓地的这张卡除外才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c25419323.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方战斗阶段开始时，把基本分支付一半才能发动。在自己场上把1只「恐啡肽狂龙衍生物」（恐龙族·暗·10星·攻0/守3000）特殊召唤。这个回合，只要这个效果特殊召唤的衍生物在自己场上存在，对方不能选择其他怪兽作为攻击对象。
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
	-- 设置②效果的发动代价为把墓地中的这张卡除外，使用aux.bfgcost辅助函数处理除外自身作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c25419323.damop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：当前必须是对手的战斗阶段开始时（战斗阶段开始且当前回合玩家为对手）。
function c25419323.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为战斗阶段开始，且当前回合玩家不是效果发动者，即对方战斗阶段开始时。
	return Duel.GetCurrentPhase()==PHASE_BATTLE_START and Duel.GetTurnPlayer()==1-tp
end
-- 定义①效果的发动代价：支付基本分的一半（向下取整）作为发动的COST。
function c25419323.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让发动者支付当前LP数值一半的LP作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义①效果的发动目标合法性检测：需要自己主要怪兽区有空位，且能够特殊召唤对应的衍生物。
function c25419323.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己场上主要怪兽区可用空格大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己可以特殊召唤卡号25419324的「恐啡肽狂龙衍生物」（恐龙族·暗·10星·攻0/守3000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,25419324,0,TYPES_TOKEN_MONSTER,0,3000,10,RACE_DINOSAUR,ATTRIBUTE_DARK) end
	-- 向连锁系统登记本次操作包含衍生物生成，预定生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向连锁系统登记本次操作包含特殊召唤，预定特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 定义①效果处理时的实际操作：先再次确认主要怪兽区有空位且可以特殊召唤该衍生物，否则不处理。
function c25419323.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查自己主要怪兽区是否没有空位，若无则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或检查无法特殊召唤该衍生物时也终止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,25419324,0,TYPES_TOKEN_MONSTER,0,3000,10,RACE_DINOSAUR,ATTRIBUTE_DARK) then return end
	-- 在自己场上生成一只卡号25419324的衍生物（「恐啡肽狂龙衍生物」）。
	local token=Duel.CreateToken(tp,25419324)
	-- 将该衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 这个回合，只要这个效果特殊召唤的衍生物在自己场上存在，对方不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c25419323.atklimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	token:RegisterEffect(e1)
end
-- 定义攻击对象过滤条件：若被选择的攻击对象不是该衍生物自身，则不允许被选择，即对方只能选择该衍生物作为攻击对象。
function c25419323.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 定义②效果的发动条件：自己基本分在2000以下，且自己即将受到战斗伤害。
function c25419323.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己的LP不大于2000，且本次战斗中自己受到的战斗伤害大于0。
	return Duel.GetLP(tp)<=2000 and Duel.GetBattleDamage(tp)>0
end
-- 定义②效果处理时的操作：给己方玩家附加“不会受到战斗伤害”的替代效果，持续到伤害步骤结束。
function c25419323.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将该“避免战斗伤害”效果注册给己方玩家，使本次战斗对自己的战斗伤害变为0。
	Duel.RegisterEffect(e1,tp)
end
