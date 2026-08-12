--茫漠の死者
-- 效果：
-- ①：自己基本分是2000以下的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合发动。这张卡的攻击力变成对方基本分一半的数值。
function c7845138.initial_effect(c)
	-- ①：自己基本分是2000以下的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c7845138.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合发动。这张卡的攻击力变成对方基本分一半的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7845138,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c7845138.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 判断自身特殊召唤规则是否满足的条件函数
function c7845138.spcon(e,c)
	if c==nil then return true end
	-- 检查控制者的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 并且控制者的基本分在2000以下
		and Duel.GetLP(c:GetControler())<=2000
end
-- 召唤·特殊召唤成功时发动效果的实际处理函数，改变自身攻击力
function c7845138.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力变成对方基本分一半的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		-- 设置攻击力数值为对方当前基本分的一半（向上取整）
		e1:SetValue(math.ceil(Duel.GetLP(1-tp)/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
