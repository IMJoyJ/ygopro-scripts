--月光舞豹姫
-- 效果：
-- 「月光舞猫姬」＋「月光」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡不会被对方的效果破坏。
-- ②：1回合1次，自己主要阶段1才能发动。这个回合，对方怪兽各有1次不会被战斗破坏，这张卡可以向全部对方怪兽各作2次攻击。
-- ③：这张卡战斗破坏对方怪兽时发动。这张卡的攻击力直到战斗阶段结束时上升200。
function c97165977.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「月光舞猫姬」和1只「月光」怪兽
	aux.AddFusionProcCodeFun(c,51777272,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c97165977.splimit)
	c:RegisterEffect(e0)
	-- ①：这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设定破坏抗性的来源为对方玩家的效果
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段1才能发动。这个回合，对方怪兽各有1次不会被战斗破坏，这张卡可以向全部对方怪兽各作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97165977,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c97165977.condition)
	e3:SetOperation(c97165977.operation)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏对方怪兽时发动。这张卡的攻击力直到战斗阶段结束时上升200。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97165977,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检查自身是否在战斗中将对方怪兽破坏
	e4:SetCondition(aux.bdocon)
	e4:SetOperation(c97165977.atkop)
	c:RegisterEffect(e4)
end
-- 限制从额外卡组特殊召唤时必须是融合召唤
function c97165977.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 限制该效果只能在自己可以进入战斗阶段的阶段（主要阶段1）发动
function c97165977.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段（即处于主要阶段1）
	return Duel.IsAbleToEnterBP()
end
-- 执行主要阶段1发动效果的实际处理，使对方怪兽获得战斗破坏抗性并使自身可以对所有怪兽各攻击2次
function c97165977.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，对方怪兽各有1次不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c97165977.indct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将对方怪兽一回合一次不会被战斗破坏的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	if c:IsRelateToEffect(e) then
		-- 这张卡可以向全部对方怪兽各作2次攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(2)
		c:RegisterEffect(e2)
	end
end
-- 判定破坏原因为战斗破坏时，提供1次免于破坏的抗性
function c97165977.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 执行战斗破坏对方怪兽时的攻击力上升效果
function c97165977.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到战斗阶段结束时上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
