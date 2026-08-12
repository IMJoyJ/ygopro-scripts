--デストーイ・チェーン・シープ
-- 效果：
-- 「锋利小鬼·链子」＋「毛绒动物」怪兽
-- 「魔玩具·链绵羊」的②的效果1回合只能使用1次。
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡的攻击力上升800。
function c57477163.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤素材为「锋利小鬼·链子」+ 1只「毛绒动物」怪兽
	aux.AddFusionProcCodeFun(c,61173621,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),1,true,true)
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c57477163.actcon)
	c:RegisterEffect(e1)
	-- 「魔玩具·链绵羊」的②的效果1回合只能使用1次。②：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,57477163)
	e2:SetCondition(c57477163.condition)
	e2:SetTarget(c57477163.target)
	e2:SetOperation(c57477163.operation)
	c:RegisterEffect(e2)
end
-- 效果①（封锁效果发动）的生效条件函数
function c57477163.actcon(e)
	-- 判断这张卡是否是当前战斗的攻击怪兽或被攻击对象
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 效果②（墓地特召）的发动条件函数：被战斗破坏，或在己方场上被对方的效果破坏并送去墓地
function c57477163.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
end
-- 效果②的发动检测与操作信息设置函数
function c57477163.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时我方场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数：特殊召唤自身并使其攻击力上升800
function c57477163.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡在墓地且未失去关联，并执行特殊召唤的第一步（表侧表示特召）
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的攻击力上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
