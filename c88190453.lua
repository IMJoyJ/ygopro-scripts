--チェイン・スラッシャー
-- 效果：
-- 这张卡可以在通常的攻击之外再增加和自己墓地存在的「链击者」相同的数目，在同1次的战斗阶段中进行攻击。
function c88190453.initial_effect(c)
	-- 这张卡可以在通常的攻击之外再增加和自己墓地存在的「链击者」相同的数目，在同1次的战斗阶段中进行攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(c88190453.val)
	c:RegisterEffect(e1)
end
-- 定义计算增加攻击次数的Value函数
function c88190453.val(e,c)
	-- 计算并返回自己墓地中卡名为「链击者」的卡片数量
	return Duel.GetMatchingGroupCount(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,88190453)
end
