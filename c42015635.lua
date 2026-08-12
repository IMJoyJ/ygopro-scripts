--ネオスペース
-- 效果：
-- 「元素英雄 新宇侠」以及用「元素英雄 新宇侠」作为融合素材的融合怪兽的攻击力上升500。用「元素英雄 新宇侠」作为融合素材的融合怪兽在结束阶段时可以不发动回到卡组效果。
function c42015635.initial_effect(c)
	-- 记录该卡与「元素英雄 新宇侠」（卡号89943723）的关联关系
	aux.AddCodeList(c,89943723)
	-- 为该卡添加「元素英雄」系列编码（0x3008），用于后续系列判定
	aux.AddSetNameMonsterList(c,0x3008)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「元素英雄 新宇侠」以及用「元素英雄 新宇侠」作为融合素材的融合怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c42015635.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 用「元素英雄 新宇侠」作为融合素材的融合怪兽在结束阶段时可以不发动回到卡组效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(42015635)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e3)
end
-- 定义用于判断目标怪兽是否满足攻击力上升条件的函数
function c42015635.atktg(e,c)
	-- 判断目标怪兽是否为「元素英雄 新宇侠」或是否以「元素英雄 新宇侠」为融合素材的融合怪兽
	return c:IsCode(89943723) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
