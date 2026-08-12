--ナチュル・スパイダーファング
-- 效果：
-- 这张卡若不在对方把魔法·陷阱·效果怪兽的效果发动的回合则不能攻击宣言。
function c25654671.initial_effect(c)
	-- 这张卡若不在对方把魔法·陷阱·效果怪兽的效果发动的回合则不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetCondition(c25654671.atkcon)
	c:RegisterEffect(e1)
	-- 设置代号为25654671、类型为发动效果的计数器，用于记录对方在该回合是否发动过魔法·陷阱·效果怪兽的效果
	Duel.AddCustomActivityCounter(25654671,ACTIVITY_CHAIN,aux.FALSE)
end
-- 判断对方在本回合是否发动过魔法·陷阱·效果怪兽的效果，若为0则满足条件
function c25654671.atkcon(e)
	-- 获取对方在本回合发动效果的次数，若为0则返回true，表示满足不能攻击宣言的条件
	return Duel.GetCustomActivityCount(25654671,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)==0
end
