--ユーフォロイド・ファイター
-- 效果：
-- 「飞碟机人」＋战士族怪兽
-- 这只怪兽融合召唤只能用上记的卡进行。这张卡的原本的攻击力·守备力，变成融合素材的2只怪兽的原本的攻击力合计的数值。
function c32752319.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求使用卡号为7602840的怪兽和1个战士族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,7602840,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,false,false)
	-- 这只怪兽融合召唤只能用上记的卡进行。这张卡的原本的攻击力·守备力，变成融合素材的2只怪兽的原本的攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32752319.atkcon)
	e1:SetOperation(c32752319.atkop)
	c:RegisterEffect(e1)
end
-- 判断该怪兽是否为融合召唤成功
function c32752319.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 遍历融合素材怪兽，计算其原本攻击力总和，并设置为自身原本攻击力和守备力
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
		-- 将自身原本攻击力设置为计算出的总和
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
