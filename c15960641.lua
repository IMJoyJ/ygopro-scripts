--ミラージュ・ドラゴン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方在战斗阶段不能把陷阱卡发动。
function c15960641.initial_effect(c)
	-- 效果原文内容：①：只要这张卡在怪兽区域存在，对方在战斗阶段不能把陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetCondition(c15960641.con)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c15960641.aclimit)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断当前是否处于战斗阶段（战斗阶段开始到战斗阶段结束）
function c15960641.con(e)
	-- 规则层面作用：获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 规则层面作用：限制对方发动陷阱卡效果
function c15960641.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
