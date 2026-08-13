--月光舞獅子姫
-- 效果：
-- 「月光舞豹姬」＋「月光」怪兽×2
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，这张卡向怪兽攻击的伤害步骤结束时才能发动。对方场上的特殊召唤的怪兽全部破坏。
function c24550676.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要「月光舞豹姬」（卡号97165977）和2只「月光」怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,97165977,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),2,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为只能通过融合召唤方式特殊召唤，限制其他方式。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置此卡不能成为对方发动的效果的对象（当效果持有者为对方时返回true）。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置此卡不会被对方的效果破坏（当效果持有者为对方时返回true）。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 1回合1次，这张卡向怪兽攻击的伤害步骤结束时才能发动。对方场上的特殊召唤的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24550676,0))  --"特殊召唤的怪兽全部破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCountLimit(1)
	e4:SetCondition(c24550676.condition)
	e4:SetTarget(c24550676.target)
	e4:SetOperation(c24550676.operation)
	c:RegisterEffect(e4)
end
-- 效果③的发动条件：伤害步骤结束时此卡仍与战斗相关（未离场或被战斗破坏），且攻击者是此卡，并且存在攻击对象。
function c24550676.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定伤害步骤结束时此卡仍与战斗相关，且本次战斗的攻击者为此卡，且存在攻击对象，满足“向怪兽攻击的伤害步骤结束时”。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()
end
-- 筛选条件为怪兽的召唤类型是特殊召唤，用于选出对方场上特殊召唤的怪兽。
function c24550676.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果③的发动时处理：确认对方场上有特殊召唤的怪兽可被破坏，并获取这些怪兽，设置破坏的操作信息。
function c24550676.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方场上必须存在至少1只特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24550676.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽，作为可能被破坏的卡集合。
	local g=Duel.GetMatchingGroup(c24550676.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果为破坏效果，破坏对象为上述怪兽，数量为g的数量，影响区域为对方场上。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果③处理时的操作：重新获取对方场上全部特殊召唤的怪兽，并将其全部破坏。
function c24550676.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新选取对方场上所有特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(c24550676.filter,tp,0,LOCATION_MZONE,nil)
	-- 将选取的怪兽全部破坏，破坏原因为效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
