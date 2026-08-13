--ナチュル・スパイダーファング
-- 效果：
-- 这张卡若不在对方把魔法·陷阱·效果怪兽的效果发动的回合则不能攻击宣言。
function c25654671.initial_effect(c)
	-- 对应效果原文：“这张卡若不在对方把魔法·陷阱·效果怪兽的效果发动的回合则不能攻击宣言。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetCondition(c25654671.atkcon)
	c:RegisterEffect(e1)
	-- 注册一个名为25654671的自定义活动计数器，监视“发动效果”（ACTIVITY_CHAIN）操作；过滤函数aux.FALSE始终返回false，因此任意玩家每发动一次魔法·陷阱·效果怪兽的效果，对应玩家的该活动计数就会增加，用于本回合是否发动过效果的判定。
	Duel.AddCustomActivityCounter(25654671,ACTIVITY_CHAIN,aux.FALSE)
end
-- 定义效果的条件函数c25654671.atkcon：当对方玩家本回合发动魔法·陷阱·效果怪兽的效果的次数为0时，条件成立，使“不能攻击宣言”效果生效；否则不禁止攻击宣言。
function c25654671.atkcon(e)
	-- 查询对方玩家本回合的ACTIVITY_CHAIN自定义活动计数，并判断是否为0；返回true表示对方本回合没有发动过任何魔法·陷阱·效果怪兽效果，满足不能攻击宣言的条件。
	return Duel.GetCustomActivityCount(25654671,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)==0
end
