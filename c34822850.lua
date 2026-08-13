--煉獄の氾爛
-- 效果：
-- ①：自己准备阶段才能发动。在自己场上把1只「狱火机衍生物」（恶魔族·炎·1星·攻/守0）特殊召唤。
-- ②：「狱火机」怪兽用自身的方法特殊召唤的场合，从自己场上也能把「狱火机」怪兽除外。
-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内除等级最高的怪兽以外的「狱火机」怪兽作为攻击对象，对方不能以此类作为效果的对象。
function c34822850.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段才能发动。在自己场上把1只「狱火机衍生物」（恶魔族·炎·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c34822850.spcon)
	e2:SetTarget(c34822850.sptg)
	e2:SetOperation(c34822850.spop)
	c:RegisterEffect(e2)
	-- ②：「狱火机」怪兽用自身的方法特殊召唤的场合，从自己场上也能把「狱火机」怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_GRAVE,0)
	e3:SetTarget(c34822850.efftg)
	e3:SetCode(34822850)
	c:RegisterEffect(e3)
	-- ③：对方怪兽不能选择在自己场上的「狱火机」怪兽之内除等级最高的怪兽以外的「狱火机」怪兽作为攻击对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c34822850.atlimit)
	c:RegisterEffect(e4)
	-- 对方不能以此类作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c34822850.tglimit)
	-- 设置“不能成为效果对象”的判定值为aux.tgoval，使只有对方发动的效果不能选择我方符合条件的「狱火机」怪兽作为对象。
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
-- e2的发动条件：当前回合玩家必须是自己，即在己方准备阶段时才能发动。
function c34822850.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家等于这张卡的控制者tp，确保只在控制者自己的准备阶段满足触发条件。
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动时的合法性检查：确认自己有可用怪兽区，且可以特殊召唤「狱火机衍生物」（恶魔族·炎·1星·攻/守0）。
function c34822850.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 要求自己场上存在空的怪兽区，以准备放置衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 要求当前玩家能够合法特殊召唤「狱火机衍生物」token，即满足衍生物特殊召唤的所有条件。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) end
	-- 设置操作信息：本次连锁将生成1只衍生物，供其他卡牌效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次连锁将进行1次特殊召唤，供其他卡牌效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时先进行条件复核：若此卡不在场、场上无怪兽区空位、或无法特殊召唤衍生物，则效果不处理。
function c34822850.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e)
		-- 若自己场上没有可用的怪兽区，则衍生物无法特殊召唤，效果处理终止。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若当前玩家已不能特殊召唤「狱火机衍生物」，则效果处理终止。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,34822851,0xbb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_FIRE) then return end
	-- 在场上生成1只「狱火机衍生物」（卡号34822851）的衍生物实体。
	local token=Duel.CreateToken(tp,34822851)
	-- 将衍生物以表侧攻击表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- e3的效果对象筛选：只有卡名属于「狱火机」系列的怪兽才会受该效果影响。
function c34822850.efftg(e,c)
	return c:IsSetCard(0xbb)
end
-- 过滤函数：用于检测是否存在表侧表示、属于「狱火机」系列且等级大于lv的怪兽。
function c34822850.filter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:GetLevel()>lv
end
-- 攻击对象限制判定：对方不能选择表侧表示且属于「狱火机」的怪兽作为攻击对象，除非该怪兽是己方场上等级最高的「狱火机」怪兽；没有等级的「狱火机」怪兽不满足最高等级条件，因此也不能被选为攻击对象。
function c34822850.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
		-- 若该「狱火机」怪兽没有等级，或场上有其他等级更高的表侧「狱火机」怪兽，则它不属于最高等级，对方不能将其选为攻击对象。
		and (not c:IsHasLevel() or Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel()))
end
-- 效果对象限制判定：对方不能选择己方场上不是最高等级（包括无等级）的「狱火机」怪兽作为效果对象。
function c34822850.tglimit(e,c)
	return c:IsSetCard(0xbb)
		-- 检测己方场上是否存在另一只表侧表示且等级更高的「狱火机」怪兽，若存在则当前怪兽不是最高等级，不能成为对方效果的对象。
		and Duel.IsExistingMatchingCard(c34822850.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetLevel())
end
