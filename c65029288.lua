--EMオッドアイズ・メタル・クロウ
-- 效果：
-- 「异色眼」怪兽＋「娱乐伙伴」怪兽
-- 这张卡不能作为融合素材。
-- ①：「融合」的效果融合召唤的这张卡不受其他卡的效果影响。
-- ②：这张卡的攻击宣言时发动。自己场上的全部怪兽的攻击力直到战斗阶段结束时上升300。
function c65029288.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「异色眼」怪兽和「娱乐伙伴」怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x99),aux.FilterBoolFunction(Card.IsFusionSetCard,0x9f),true)
	-- 这张卡不能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：「融合」的效果融合召唤的这张卡不受其他卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c65029288.immcon)
	e2:SetOperation(c65029288.immop)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击宣言时发动。自己场上的全部怪兽的攻击力直到战斗阶段结束时上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65029288,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetOperation(c65029288.atkop)
	c:RegisterEffect(e3)
end
-- 判断是否是由「融合」的效果进行的融合召唤
function c65029288.immcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(24094653) and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 在融合召唤成功时，为自身注册不受其他卡效果影响的永续效果
function c65029288.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65029288,0))  --"「融合」的效果融合召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c65029288.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 免疫效果的过滤函数，判定效果来源是否为其他卡
function c65029288.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 攻击宣言时效果的实际处理：使自己场上所有表侧表示怪兽的攻击力直到战斗阶段结束时上升300
function c65029288.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部怪兽的攻击力直到战斗阶段结束时上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
