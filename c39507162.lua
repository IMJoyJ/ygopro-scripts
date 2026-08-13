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
-- 攻击力上升效果的适用条件判断函数：检查这张卡的控制者手牌数量是否为1张以下，满足则①效果的攻击力上升适用。
function c39507162.atkcon(e)
	-- 统计这张卡控制者的手牌数量，判断是否≤1，用于①效果“自己手卡是1张以下”的适用条件。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)<=1
end
-- ②效果的适用条件判断函数：检查这张卡的控制者场上是否存在除这张卡以外的怪兽，若不存在则条件成立。
function c39507162.discon(e)
	-- 以这张卡自身为排除对象，检查其控制者场上是否存在其他怪兽；不存在时返回true，用于②效果“没有这张卡以外的怪兽存在”的条件。
	return not Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 战斗伤害计算后处理：获取与这张卡战斗的怪兽，若该怪兽处于战斗破坏确定状态且为反转怪兽，则赋予其“怪兽效果无效”和“效果无效化”两个状态，并在该怪兽离场时重置。
function c39507162.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsType(TYPE_FLIP) then
		-- ②：自己场上没有这张卡以外的怪兽存在的场合，这张卡战斗破坏的反转怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- ②：自己场上没有这张卡以外的怪兽存在的场合，这张卡战斗破坏的反转怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
