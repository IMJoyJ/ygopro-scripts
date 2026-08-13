--サイバース・ウィザード
-- 效果：
-- ①：1回合1次，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。这个效果变成守备表示的回合，自己怪兽只能向作为对象的怪兽攻击，自己的电子界族怪兽向作为对象的守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c36033786.initial_effect(c)
	-- ①：1回合1次，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。这个效果变成守备表示的回合，自己怪兽只能向作为对象的怪兽攻击，自己的电子界族怪兽向作为对象的守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetDescription(aux.Stringid(36033786,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c36033786.postg)
	e1:SetOperation(c36033786.posop)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择对方场上表侧攻击表示且能被效果改变表示形式的怪兽。
function c36033786.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果发动时的目标选择与合法性检查：确认存在符合条件的对方怪兽，提示玩家选择1只对方场上的表侧攻击表示怪兽作为对象，并设置操作信息为改变表示形式。
function c36033786.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c36033786.posfilter(chkc) end
	-- 在发动合法性检查（chk==0）时，检查对方场上是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36033786.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家从对方场上选择1只符合条件的表侧攻击表示怪兽作为本效果的对象。
	local g=Duel.SelectTarget(tp,c36033786.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁将改变1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数：若目标仍与效果相关，将其变为守备表示，然后为本回合适用不能直接攻击、攻击对象限制以及电子界族贯穿伤害的持续效果。
function c36033786.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，且成功将其变更为表侧守备表示后，才继续适用后续攻击限制与贯穿效果。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		local fid=tc:GetRealFieldID()
		-- 这个效果变成守备表示的回合，自己怪兽只能向作为对象的怪兽攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果e1：使自己在主要怪兽区的怪兽本回合不能直接攻击（持续到结束阶段）。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetValue(c36033786.atklimit)
		e2:SetLabel(fid)
		-- 注册效果e2：使对方在攻击时只能选择带有记录ID的目标（即本效果变为守备表示的那只对象怪兽）作为攻击对象。
		Duel.RegisterEffect(e2,tp)
		-- 自己的电子界族怪兽向作为对象的守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		-- 将贯穿伤害效果的适用对象限定为持有电子界族的我方怪兽。
		e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_CYBERSE))
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果e3：我方电子界族怪兽在攻击守备表示怪兽时，给予对方攻击力超过守备力的战斗伤害，持续到结束阶段。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 限制攻击目标的过滤函数：通过比较卡片真实场地ID与效果记录的ID，判断当前攻击对象是否为本次效果变为守备表示的那只对象怪兽（ID不同则不能选择攻击）。
function c36033786.atklimit(e,c)
	return c:GetRealFieldID()~=e:GetLabel()
end
