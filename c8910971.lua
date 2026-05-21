--暗黒騎士ガイアロード
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，比这张卡攻击力高的怪兽在对方场上特殊召唤的场合才能发动。这张卡的攻击力直到回合结束时上升700。
function c8910971.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c8910971.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，比这张卡攻击力高的怪兽在对方场上特殊召唤的场合才能发动。这张卡的攻击力直到回合结束时上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8910971,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c8910971.condition)
	e2:SetOperation(c8910971.operation)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤规则的条件函数
function c8910971.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤出对方场上表侧表示且攻击力比当前卡片高的怪兽
function c8910971.cfilter(c,tp,atk)
	return c:IsFaceup() and c:IsControler(1-tp) and c:GetAttack()>atk
end
-- 判断本次特殊召唤的怪兽中是否存在满足条件的怪兽
function c8910971.condition(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetHandler():GetAttack()
	return eg:IsExists(c8910971.cfilter,1,nil,tp,atk)
end
-- 执行效果：使这张卡的攻击力直到回合结束时上升700
function c8910971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
