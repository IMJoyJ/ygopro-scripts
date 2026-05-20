--ジュラック・ギガノト
-- 效果：
-- 调整＋调整以外的恐龙族怪兽1只以上
-- ①：只要这张卡在怪兽区域存在，自己场上的「朱罗纪」怪兽的攻击力上升自己墓地的「朱罗纪」怪兽数量×200。
function c80032567.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的恐龙族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DINOSAUR),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的「朱罗纪」怪兽的攻击力上升自己墓地的「朱罗纪」怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为「朱罗纪」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x22))
	e1:SetValue(c80032567.val)
	c:RegisterEffect(e1)
end
-- 过滤条件：字段名含有「朱罗纪」的怪兽卡
function c80032567.filter(c)
	return c:IsSetCard(0x22) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升值的函数
function c80032567.val(e,c)
	-- 返回自己墓地的「朱罗纪」怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(c80032567.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*200
end
