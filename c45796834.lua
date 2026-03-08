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
	-- 设置战斗伤害变为2倍
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
-- 判断装备卡数量是否满足效果条件，并检查是否处于战斗阶段或满足其他特殊条件
function c45796834.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lab=e:GetLabel()
	if c:GetEquipCount()<lab then return false end
	if (lab==2 or lab==4) then
		-- 判断当前是否处于战斗阶段
		return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
	elseif lab==3 then
		if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
			return false
		end
		-- 获取连锁效果的目标卡片组
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		-- 判断目标卡片组是否包含自身且该连锁效果可被无效
		return g and g:IsContains(c) and Duel.IsChainDisablable(ev)
	else
		return true
	end
end
-- 返回装备卡数量乘以1000作为攻击力加成
function c45796834.atkval(e,c)
	return c:GetEquipCount()*1000
end
-- 返回效果类型为怪兽卡，用于限制对方不能发动怪兽效果
function c45796834.actlimit(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数，用于选择场上可送入墓地的装备卡作为发动代价
function c45796834.negfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 发动效果时选择一张场上装备卡送入墓地作为代价
function c45796834.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可送入墓地的装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45796834.negfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送入墓地的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张场上装备卡作为发动代价
	local g=Duel.SelectMatchingCard(tp,c45796834.negfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的装备卡送入墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置连锁操作信息，表示将使效果无效
function c45796834.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效
function c45796834.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
