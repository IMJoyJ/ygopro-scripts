--ネオスペース
-- 效果：
-- 「元素英雄 新宇侠」以及用「元素英雄 新宇侠」作为融合素材的融合怪兽的攻击力上升500。用「元素英雄 新宇侠」作为融合素材的融合怪兽在结束阶段时可以不发动回到卡组效果。
function c42015635.initial_effect(c)
	-- 为这张场地魔法卡登记卡名「元素英雄 新宇侠」（89943723），以便后续正确判断与「元素英雄 新宇侠」相关的融合素材。
	aux.AddCodeList(c,89943723)
	-- 给这张卡注册「元素英雄」系列字段（0x3008），使效果文本中涉及「元素英雄 新宇侠」及其融合怪兽的判定能识别该系列。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「元素英雄 新宇侠」以及用「元素英雄 新宇侠」作为融合素材的融合怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c42015635.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 用「元素英雄 新宇侠」作为融合素材的融合怪兽在结束阶段时可以不发动回到卡组效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(42015635)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e3)
end
-- 定义攻击力上升效果的对象筛选函数：符合条件的怪兽是「元素英雄 新宇侠」，或是融合怪兽且其融合素材中包含「元素英雄 新宇侠」。
function c42015635.atktg(e,c)
	-- 返回真当且仅当对象卡名是「元素英雄 新宇侠」，或者对象是融合怪兽并且它的融合素材名单中记载了「元素英雄 新宇侠」。
	return c:IsCode(89943723) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
end
