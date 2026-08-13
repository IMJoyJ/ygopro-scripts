--ユーフォロイド・ファイター
-- 效果：
-- 「飞碟机人」＋战士族怪兽
-- 这只怪兽融合召唤只能用上记的卡进行。这张卡的原本的攻击力·守备力，变成融合素材的2只怪兽的原本的攻击力合计的数值。
function c32752319.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只「飞碟机人」（卡号7602840）和1只战士族怪兽作为融合素材，且不能用其他素材代替（sub=false），从而还原「只能以上记之卡进行融合召唤」的召唤限制。
	aux.AddFusionProcCodeFun(c,7602840,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,false,false)
	-- 这张卡的原本的攻击力·守备力，变成融合素材的2只怪兽的原本的攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32752319.atkcon)
	e1:SetOperation(c32752319.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当这张卡为融合召唤成功时返回true，用于过滤非融合召唤的特殊召唤，确保后述效果只在融合召唤成功时触发。
function c32752319.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤成功时，获取这张卡的融合召唤素材，累加所有素材的原本攻击力得到合计值；若合计值不为0，则将自身的原本攻击力和原本守备力都设置为该合计数值，并设定这些数值在卡片离场、回到手牌/卡组/墓地等标准重置事件发生或效果被无效时重置。
function c32752319.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	while tc do
		local catk=tc:GetBaseAttack()
		atk=atk+catk
		tc=g:GetNext()
	end
	if atk~=0 then
		-- 这张卡的原本的攻击力·守备力，变成融合素材的2只怪兽的原本的攻击力合计的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
