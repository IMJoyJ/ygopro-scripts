--幻影騎士団トゥーム・シールド
-- 效果：
-- ①：这张卡发动后变成通常怪兽（战士族·暗·3星·攻/守0）在怪兽区域攻击表示特殊召唤（不当作陷阱卡使用）。
-- ②：自己回合把墓地的这张卡除外，以对方场上1张表侧表示的陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在这张卡送去墓地的回合不能发动。
function c51606429.initial_effect(c)
	-- ①：这张卡发动后变成通常怪兽（战士族·暗·3星·攻/守0）在怪兽区域攻击表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c51606429.target)
	e1:SetOperation(c51606429.activate)
	c:RegisterEffect(e1)
	-- ②：自己回合把墓地的这张卡除外，以对方场上1张表侧表示的陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51606429,0))  --"表侧表示的陷阱卡效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c51606429.negcon)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51606429.negtg)
	e2:SetOperation(c51606429.negop)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤条件
function c51606429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡为通常怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51606429,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c51606429.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认此卡可以被特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,51606429,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡以攻击表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
	end
end
-- 设置效果发动条件
function c51606429.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为自己的回合且不是在送去墓地的回合
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于筛选对方场上的表侧表示陷阱卡
function c51606429.negfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and not c:IsDisabled()
end
-- 设置取对象效果的目标选择逻辑
function c51606429.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51606429.negfilter(chkc) end
	-- 检查是否存在符合条件的敌方场上表侧表示陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c51606429.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标陷阱卡
	Duel.SelectTarget(tp,c51606429.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 执行效果处理操作
function c51606429.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果在回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽的效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
