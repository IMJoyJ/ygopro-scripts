--炎の護封剣
-- 效果：
-- 自己场上没有怪兽存在的场合，对方场上的怪兽不能攻击宣言。自己场上有怪兽存在的场合或者对方手卡是5张以上的场合，这张卡破坏。
function c93087299.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上没有怪兽存在的场合，对方场上的怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c93087299.atcon)
	c:RegisterEffect(e2)
	-- 自己场上有怪兽存在的场合或者对方手卡是5张以上的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c93087299.descon)
	c:RegisterEffect(e3)
end
-- 定义对方不能攻击宣言效果的适用条件
function c93087299.atcon(e)
	-- 判断自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
-- 定义这张卡自我破坏效果的适用条件
function c93087299.descon(e)
	-- 判断自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)~=0
		-- 或者对方手牌数量是否在5张以上
		or Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)>=5
end
