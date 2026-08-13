--ゴーストリック・ハウス
-- 效果：
-- ①：只要这张卡在场地区域存在，双方怪兽不能向里侧守备表示怪兽攻击，可以在对方场上的怪兽只有里侧守备表示怪兽的场合向对方直接攻击。
-- ②：只要这张卡在场地区域存在，双方受到的效果伤害变成一半，「鬼计」怪兽以外的怪兽给与玩家的战斗伤害变成一半。
function c99795159.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，双方怪兽不能向里侧守备表示怪兽攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置“不能选择为攻击对象”的判定条件：若目标怪兽是里侧守备表示则返回真，使双方怪兽不能攻击里侧守备表示怪兽
	e2:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e2)
	-- 可以在对方场上的怪兽只有里侧守备表示怪兽的场合向对方直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c99795159.dirtg)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，双方受到的效果伤害变成一半
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetValue(c99795159.val)
	c:RegisterEffect(e4)
	-- 「鬼计」怪兽以外的怪兽给与玩家的战斗伤害变成一半。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c99795159.rdtg)
	e5:SetValue(HALF_DAMAGE)
	c:RegisterEffect(e5)
end
-- 直接攻击的允许判定函数：若攻击怪兽的控制者的对方场上不存在表侧表示怪兽（即只有里侧守备表示怪兽），则允许该怪兽直接攻击
function c99795159.dirtg(e,c)
	-- 以攻击怪兽控制者视角检查对方场上是否存在至少1张表侧表示怪兽；不存在则返回真，允许直接攻击
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 效果伤害减半的值函数：若伤害原因包含效果伤害（REASON_EFFECT），则将伤害数值向下取整为一半；否则保持原伤害数值
function c99795159.val(e,re,dam,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then
		return math.floor(dam/2)
	else return dam end
end
-- 战斗伤害减半的目标筛选：当战斗伤害来源怪兽不是“鬼计”系列时返回真，即非鬼计怪兽造成的战斗伤害减半
function c99795159.rdtg(e,c)
	return not c:IsSetCard(0x8d)
end
