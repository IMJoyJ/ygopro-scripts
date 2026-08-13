--光天のマハー・ヴァイロ
-- 效果：
-- ①：这张卡得到这张卡的装备卡数量的以下效果。
-- ●1张以上：这张卡的攻击力上升这张卡的装备卡数量×1000。
-- ●2张以上：对方在战斗阶段中不能把怪兽的效果发动。
-- ●3张以上：这张卡为对象的对方的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个效果无效。
-- ●4张以上：对方在战斗阶段中不能把卡的效果发动。
-- ●5张以上：这张卡给与对方的战斗伤害变成2倍。
function c45796834.initial_effect(c)
	-- ●1张以上：这张卡的攻击力上升这张卡的装备卡数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(1)
	e1:SetCondition(c45796834.eqcon)
	e1:SetValue(c45796834.atkval)
	c:RegisterEffect(e1)
	-- ●2张以上：对方在战斗阶段中不能把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetLabel(2)
	e2:SetCondition(c45796834.eqcon)
	e2:SetValue(c45796834.actlimit)
	c:RegisterEffect(e2)
	-- ●3张以上：这张卡为对象的对方的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(3)
	e3:SetCondition(c45796834.eqcon)
	e3:SetCost(c45796834.negcost)
	e3:SetTarget(c45796834.negtg)
	e3:SetOperation(c45796834.negop)
	c:RegisterEffect(e3)
	-- ●4张以上：对方在战斗阶段中不能把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetLabel(4)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c45796834.eqcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ●5张以上：这张卡给与对方的战斗伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetLabel(5)
	e5:SetCondition(c45796834.eqcon)
	-- 设置该效果为“此卡给与对方的战斗伤害变成2倍”的伤害变更值。
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
-- 公共条件函数：先检查装备卡数量是否达到本效果标签lab；lab为2或4时额外要求处于战斗阶段；lab为3时额外要求是对方发动的以此卡为对象的取对象效果且该连锁可被无效；其余情况仅需装备数达标。
function c45796834.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lab=e:GetLabel()
	if c:GetEquipCount()<lab then return false end
	if (lab==2 or lab==4) then
		-- 返回当前是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）。
		return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
	elseif lab==3 then
		if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
			return false
		end
		-- 获取当前连锁ev中取对象效果的对象卡组，用于判断本卡是否为对象。
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		-- 当对象卡组包含本卡且该连锁效果能够被无效时返回真，作为3号效果的发动条件。
		return g and g:IsContains(c) and Duel.IsChainDisablable(ev)
	else
		return true
	end
end
-- 返回这张卡的装备卡数量×1000，作为攻击力上升数值。
function c45796834.atkval(e,c)
	return c:GetEquipCount()*1000
end
-- 作为EFFECT_CANNOT_ACTIVATE的判定值：对方发动的效果是怪兽效果时返回真，从而禁止其在战斗阶段发动怪兽效果。
function c45796834.actlimit(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 筛选可作为代价的装备卡：是装备卡，且（表侧表示或正装备于怪兽）且可以作为代价送去墓地。
function c45796834.negfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 代价函数：在合法性检查时确认存在至少1张符合条件的装备卡；发动时从自己魔陷区选择1张装备卡送去墓地。
function c45796834.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）判断是否存在至少1张符合条件的装备卡，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c45796834.negfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己魔陷区选择1张满足negfilter条件的装备卡，作为本次代价支付的卡。
	local g=Duel.SelectMatchingCard(tp,c45796834.negfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的装备卡以“代价（REASON_COST）”原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数：本效果不取对象，允许发动；并设置操作信息，声明将对目标连锁进行无效处理。
function c45796834.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将对eg对应的效果进行无效化，类别为CATEGORY_DISABLE。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理函数：发动成功后实际执行无效操作，使对方发动的对应效果无效。
function c45796834.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的效果无效化。
	Duel.NegateEffect(ev)
end
