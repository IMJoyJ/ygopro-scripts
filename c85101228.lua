--D・バインド
-- 效果：
-- 只要自己场上有名字带有「变形斗士」的怪兽表侧表示存在，对方场上存在的4星以上的怪兽不能攻击宣言，也不能把表示形式改变。
function c85101228.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要自己场上有名字带有「变形斗士」的怪兽表侧表示存在，对方场上存在的4星以上的怪兽不能攻击宣言
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c85101228.tg)
	e2:SetCondition(c85101228.con)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)
end
-- 过滤表侧表示且卡名含有「变形斗士」的怪兽
function c85101228.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x26)
end
-- 定义效果生效的条件函数，即自己场上存在表侧表示的「变形斗士」怪兽
function c85101228.con(e)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c85101228.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 定义效果影响的目标过滤函数，即等级在4星以上的怪兽
function c85101228.tg(e,c)
	return c:IsLevelAbove(4)
end
