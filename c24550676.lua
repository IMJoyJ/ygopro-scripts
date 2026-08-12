--月光舞獅子姫
-- 效果：
-- 「月光舞豹姬」＋「月光」怪兽×2
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，这张卡向怪兽攻击的伤害步骤结束时才能发动。对方场上的特殊召唤的怪兽全部破坏。
function c24550676.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为97165977的怪兽和2个满足「月光」融合素材条件的怪兽进行融合召唤
	aux.AddFusionProcCodeFun(c,97165977,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),2,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过融合召唤方式特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该卡不会被对方效果破坏
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置该卡不能成为对方效果的对象
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
-- 判断是否满足发动条件：该卡参与了战斗且处于伤害步骤结束时
function c24550676.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 该卡参与了战斗且处于伤害步骤结束时
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()
end
-- 过滤函数，用于判断目标怪兽是否为特殊召唤
function c24550676.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果目标：对方场上满足条件的怪兽
function c24550676.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：对方场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24550676.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c24550676.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：将满足条件的怪兽全部破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置效果处理：破坏对方场上满足条件的怪兽
function c24550676.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c24550676.filter,tp,0,LOCATION_MZONE,nil)
	-- 将满足条件的怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
