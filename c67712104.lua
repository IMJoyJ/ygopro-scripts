--海晶乙女クリスタルハート
-- 效果：
-- 水属性怪兽2只
-- ①：这张卡只要在额外怪兽区域存在，不受对方怪兽的效果影响。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤内，那只对方怪兽不受自身以外的卡的效果影响。
-- ③：这张卡或者这张卡所连接区的自己的「海晶少女」连接怪兽被选择作为攻击对象时，从手卡把1只「海晶少女」怪兽送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
function c67712104.initial_effect(c)
	-- 设置连接召唤手续：水属性怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡只要在额外怪兽区域存在，不受对方怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c67712104.immcon1)
	e1:SetValue(c67712104.efilter1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤内，那只对方怪兽不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c67712104.immcon2)
	e2:SetTarget(c67712104.immtg2)
	e2:SetValue(c67712104.efilter2)
	c:RegisterEffect(e2)
	-- ③：这张卡或者这张卡所连接区的自己的「海晶少女」连接怪兽被选择作为攻击对象时，从手卡把1只「海晶少女」怪兽送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67712104,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c67712104.indcon)
	e3:SetCost(c67712104.indcost)
	e3:SetTarget(c67712104.indtg)
	e3:SetOperation(c67712104.indop)
	c:RegisterEffect(e3)
	if not c67712104.global_check then
		c67712104.global_check=true
		-- 「海晶少女 水晶心」为素材作连接召唤
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c67712104.valcheck)
		-- 在全局环境注册素材检查效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查连接素材中是否包含「海晶少女 水晶心」，若有则给该连接怪兽注册对应的Flag标记
function c67712104.valcheck(e,c)
	local g=c:GetMaterial()
	if c:IsType(TYPE_LINK) and g:IsExists(Card.IsLinkCode,1,nil,67712104) then
		c:RegisterFlagEffect(91027843,RESET_EVENT+0x4fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(91027843,0))  --"「海晶少女 水晶心」为素材作连接召唤"
	end
end
-- 免疫效果的条件：自身处于额外怪兽区域
function c67712104.immcon1(e)
	return e:GetHandler():GetSequence()>4
end
-- 免疫效果的过滤：不受对方怪兽的效果影响
function c67712104.efilter1(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end
-- 免疫效果的条件：在伤害步骤或伤害计算时，且自身有战斗对象
function c67712104.immcon2(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and e:GetHandler():GetBattleTarget()
end
-- 免疫效果的目标：与自身进行战斗的对方怪兽
function c67712104.immtg2(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 免疫效果的过滤：不受该对方怪兽自身以外的卡的效果影响
function c67712104.efilter2(e,te,c)
	return c~=te:GetOwner()
end
-- 效果③的发动条件：自身或自身所连接区的己方「海晶少女」连接怪兽被选择作为攻击对象
function c67712104.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象
	local at=Duel.GetAttackTarget()
	if not at then return false end
	local c=e:GetHandler()
	if at==c then return true end
	local lg=c:GetLinkedGroup()
	return at:IsControler(tp) and at:IsFaceup()
		and at:IsSetCard(0x12b) and at:IsType(TYPE_LINK) and lg:IsContains(at)
end
-- 过滤手牌中可以作为代价送去墓地的「海晶少女」怪兽
function c67712104.costfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果③的代价：从手卡把1只「海晶少女」怪兽送去墓地
function c67712104.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手牌中是否存在可送去墓地的「海晶少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67712104.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1只「海晶少女」怪兽送去墓地
	Duel.DiscardHand(tp,c67712104.costfilter,1,1,REASON_COST)
end
-- 效果③的靶向处理：使被攻击的怪兽与当前效果建立关系
function c67712104.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将被攻击的怪兽与当前效果建立联系
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
-- 效果③的效果处理：使被攻击的怪兽不会被那次战斗破坏，且那次战斗发生的对自己的战斗伤害变成0
function c67712104.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的攻击对象
	local at=Duel.GetAttackTarget()
	if at:IsRelateToEffect(e) then
		-- 那只自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		at:RegisterEffect(e1)
		-- 那次战斗发生的对自己的战斗伤害变成0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 给玩家注册“战斗伤害变成0”的效果
		Duel.RegisterEffect(e2,tp)
	end
end
