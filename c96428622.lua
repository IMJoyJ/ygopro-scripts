--サイバネティック・サイクロプス
-- 效果：
-- 只要自己手卡数目是0张，这张卡的攻击力上升1000。
function c96428622.initial_effect(c)
	-- 只要自己手卡数目是0张，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetCondition(c96428622.atkcon)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升效果的生效条件函数
function c96428622.atkcon(e)
	-- 判断自己手牌数量是否等于0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
