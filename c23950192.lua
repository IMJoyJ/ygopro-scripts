--氷結界の術者
-- 效果：
-- ①：只要自己场上有其他的「冰结界」怪兽存在，4星以上的怪兽不能攻击宣言。
function c23950192.initial_effect(c)
	-- 效果原文内容：①：只要自己场上有其他的「冰结界」怪兽存在，4星以上的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c23950192.tg)
	e2:SetCondition(c23950192.con)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在表侧表示的「冰结界」怪兽
function c23950192.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 条件函数，判断自己场上有其他「冰结界」怪兽存在
function c23950192.con(e)
	-- 检索满足条件的卡片组，检查场上是否存在至少1张符合条件的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c23950192.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 目标函数，设定被禁止攻击宣言的怪兽为等级4以上的怪兽
function c23950192.tg(e,c)
	return c:IsLevelAbove(4)
end
