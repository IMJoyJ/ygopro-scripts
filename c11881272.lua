--フェイバリット・ヒーロー
-- 效果：
-- 5星以上的「英雄」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：自己的场地区域有卡存在的场合，装备怪兽攻击力上升原本守备力数值，对方不能把装备怪兽作为效果的对象。
-- ②：自己·对方的战斗阶段开始时才能发动。从自己的手卡·卡组把1张场地魔法卡发动。
-- ③：装备怪兽的攻击破坏对方怪兽时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
function c11881272.initial_effect(c)
	-- 5星以上的「英雄」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c11881272.target)
	e1:SetOperation(c11881272.operation)
	c:RegisterEffect(e1)
	-- 5星以上的「英雄」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c11881272.eqlimit)
	c:RegisterEffect(e2)
	-- ①：自己的场地区域有卡存在的场合，装备怪兽攻击力上升原本守备力数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c11881272.atkval)
	e3:SetCondition(c11881272.atkcon)
	c:RegisterEffect(e3)
	-- 自己的场地区域有卡存在的场合，对方不能把装备怪兽作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置‘不能成为效果对象’的判定函数为aux.tgoval，用于实现‘对方不能把装备怪兽作为效果的对象’。
	e4:SetValue(aux.tgoval)
	e4:SetCondition(c11881272.atkcon)
	c:RegisterEffect(e4)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的战斗阶段开始时才能发动。从自己的手卡·卡组把1张场地魔法卡发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11881272,0))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,11881272)
	e5:SetTarget(c11881272.acttg)
	e5:SetOperation(c11881272.actop)
	c:RegisterEffect(e5)
	-- ③：装备怪兽的攻击破坏对方怪兽时，把这张卡送去墓地才能发动。那只攻击怪兽只再1次可以继续攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(11881272,1))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DESTROYING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c11881272.chacon)
	e6:SetCost(c11881272.chacost)
	e6:SetOperation(c11881272.chaop)
	c:RegisterEffect(e6)
end
-- 装备对象过滤器：要求对象为表侧表示、等级5以上且属于「英雄」（0x8）字段。
function c11881272.eqfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSetCard(0x8)
end
-- 装备魔法卡发动时的目标选择函数：确认对象合法后，选择场上1只满足条件的表侧表示「英雄」怪兽作为装备对象，并设置操作信息为装备。
function c11881272.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11881272.eqfilter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只可以成为装备对象的表侧表示、5星以上、「英雄」字段的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11881272.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示信息（请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只满足条件的表侧表示「英雄」怪兽作为这次装备效果的对象。
	Duel.SelectTarget(tp,c11881272.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：本次处理为装备效果，对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数：取得选择的对象，若此卡和对象仍与效果关联且对象仍满足装备条件，则将此卡装备给该对象。
function c11881272.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的第一个对象（即选择的装备对象）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c11881272.eqfilter(tc) then
		-- 执行装备操作：由玩家tp将此卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备限制判定：此卡只能装备给等级5以上且属于「英雄」字段的怪兽。
function c11881272.eqlimit(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x8)
end
-- 返回装备怪兽的原本守备力数值，作为攻击力上升的值。
function c11881272.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetBaseDefense()
end
-- 条件：这张卡的控制者的场地区域存在任意卡片。
function c11881272.atkcon(e)
	-- 检查自己场地区域是否存在至少1张卡。
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_FZONE,0,1,nil)
end
-- 场地魔法卡的选择过滤器：该卡是场地魔法，且其发动效果当前可以被玩家tp发动。
function c11881272.actfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- ②效果的发动条件判定：若处于战斗阶段开始时，且自己手卡·卡组中存在可以发动的场地魔法卡，则满足发动条件；同时记录当前是否为阶段开始时到标签，用于后续处理。
function c11881272.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：从手卡·卡组确认是否存在至少1张满足条件的可发动的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11881272.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 通过Duel.CheckPhaseActivity判断当前是否为阶段开始时：若未进行过其他操作则标签设为1，否则设为0，用于后续发动时处理阶段活动限制。
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- ②效果处理：提示选择后从手卡·卡组选择1张场地魔法卡并发动；若为阶段开始时则临时注册标志以允许发动；若场地区已有卡则按规则送墓并中断效果，然后将选择的卡放置到场地区域并触发其发动。
function c11881272.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择要发动的场地魔法卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11881272,2))  --"请选择要发动的场地魔法卡"
	-- 若标签为1（阶段开始时），给玩家注册一个连锁结束即重置的标志效果，用于在发动场地魔法时跳过某些阶段活动限制。
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
	-- 从自己的手卡·卡组中选择1张满足条件的场地魔法卡。
	local g=Duel.SelectMatchingCard(tp,c11881272.actfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	-- 重置上一步注册的标志效果，避免其影响后续操作。
	Duel.ResetFlagEffect(tp,11881272)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		-- 再次注册相同的标志效果，确保场地魔法发动时仍处于阶段开始时的处理流程中。
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,11881272,RESET_CHAIN,0,1) end
		local b=te:IsActivatable(tp,true,true)
		if b then
			-- 在确认场地魔法可以发动后，重置该标志效果。
			Duel.ResetFlagEffect(tp,11881272)
			-- 获取自己场地区域当前放置的卡，即已存在的场地魔法卡。
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 按规则将已有的场地魔法卡送去墓地（因为新的场地魔法卡要发动）。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续的场地魔法发动被视为另一组动作，避免错过时点。
				Duel.BreakEffect()
			end
			-- 将选择的场地魔法卡移动到自己的场地区域并表侧表示放置，同时立刻适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 以连锁发动的方式触发该场地魔法卡的发动（EVENT代码4179255）。
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
-- ③效果的发动条件判定：装备怪兽为攻击怪兽，且这次攻击破坏了对方怪兽，该怪兽仍与战斗相关且可以进行追加攻击。
function c11881272.chacon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 当前攻击者为装备怪兽，且该怪兽仍与战斗相关、攻击的是对方怪兽、并且怪兽可进行连锁攻击。
	return Duel.GetAttacker()==ec and ec:IsRelateToBattle() and ec:IsStatus(STATUS_OPPO_BATTLE) and ec:IsChainAttackable()
end
-- ③效果发动代价：将此装备卡送去墓地作为代价。
function c11881272.chacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此装备卡以COST原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ③效果处理：让攻击怪兽获得一次额外的攻击机会。
function c11881272.chaop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.ChainAttack()，使攻击怪兽可以再次进行攻击。
	Duel.ChainAttack()
end
