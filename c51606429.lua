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
	-- 设置发动②效果所需的COST：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51606429.negtg)
	e2:SetOperation(c51606429.negop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：确认是否满足发动COST检查、我方主要怪兽区有空位，以及我方能否将这张卡作为通常怪兽特殊召唤。
function c51606429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 确认我方主要怪兽区域存在可用的空格，保证特殊召唤能够进行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认我方可以将这张卡以战士族·暗·3星·攻/守0的通常怪兽形式、表侧攻击表示特殊召唤到主要怪兽区域。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51606429,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置本次效果处理的信息：该效果将对这张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：这张卡发动后，将其变成通常怪兽并在怪兽区域攻击表示特殊召唤（不当作陷阱卡使用）。
function c51606429.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认这张卡仍与效果关联，且特殊召唤条件仍然满足。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,51606429,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将这张卡以表侧攻击表示特殊召唤到主要怪兽区域，不当作陷阱卡使用。
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
	end
end
-- ②效果的发动条件：这张卡在墓地且不是送去墓地的回合、并且当前是己方回合。
function c51606429.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足“不是这张卡送去墓地的回合”这一限制条件，并且当前回合玩家是这张卡的控制者。
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp
end
-- 选择对象的过滤条件：对方场上的表侧表示陷阱卡，且尚未被无效化。
function c51606429.negfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and not c:IsDisabled()
end
-- ②效果的发动时选择对象：从对方场上选择1张表侧表示且未被无效的陷阱卡作为对象。
function c51606429.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51606429.negfilter(chkc) end
	-- 发动时确认是否存在满足条件的选择对象。
	if chk==0 then return Duel.IsExistingTarget(c51606429.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家弹出选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际选择对方场上的1张表侧表示陷阱卡，并将其锁定为本效果的对象。
	Duel.SelectTarget(tp,c51606429.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果处理：使对象陷阱卡的效果直到回合结束时无效；若该卡为陷阱怪兽，则也将其无效化。
function c51606429.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本效果发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该对象卡相关的连锁效果全部无效化，持续到回合结束。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 为对象卡赋予“效果无效”状态，使其效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为对象卡赋予“效果发动无效化”状态，使其效果不能发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若对象卡是陷阱怪兽，赋予其陷阱怪兽特殊召唤无效化的状态，使作为怪兽的效果也被无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
