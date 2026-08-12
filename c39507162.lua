--ブレイドナイト
-- 效果：
-- ①：只要自己手卡是1张以下，这张卡的攻击力上升400。
-- ②：自己场上没有这张卡以外的怪兽存在的场合，这张卡战斗破坏的反转怪兽的效果无效化。
function c39507162.initial_effect(c)
	-- ①：只要自己手卡是1张以下，这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	e1:SetCondition(c39507162.atkcon)
	c:RegisterEffect(e1)
	-- ②：自己场上没有这张卡以外的怪兽存在的场合，这张卡战斗破坏的反转怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c39507162.discon)
	e2:SetOperation(c39507162.disop)
	c:RegisterEffect(e2)
end
-- 检查当前玩家手卡数量是否小于等于1
function c39507162.atkcon(e)
	-- 检索满足条件的卡片组
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)<=1
end
-- 检查自己场上是否只有这张卡
function c39507162.discon(e)
	-- 检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
	return not Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 处理战斗破坏反转怪兽时的效果无效化
function c39507162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsType(TYPE_FLIP) then
		-- 使被战斗破坏的反转怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 使被战斗破坏的反转怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
