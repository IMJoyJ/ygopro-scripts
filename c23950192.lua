--氷結界の術者
-- 效果：
-- ①：只要自己场上有其他的「冰结界」怪兽存在，4星以上的怪兽不能攻击宣言。
function c23950192.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，4星以上的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c23950192.tg)
	e2:SetCondition(c23950192.con)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：筛选出表侧表示且具有「冰结界」字段的怪兽。
function c23950192.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 定义效果满足条件：自己场上有其他「冰结界」怪兽存在时，此限制效果才适用。
function c23950192.con(e)
	-- 检查效果控制者场上主要怪兽区是否存在至少1张除自身以外的表侧表示「冰结界」怪兽，若存在则条件成立。
	return Duel.IsExistingMatchingCard(c23950192.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义适用对象判定：等级在4星及以上的怪兽不能进行攻击宣言。
function c23950192.tg(e,c)
	return c:IsLevelAbove(4)
end
