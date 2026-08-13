--ダブルアタック
-- 效果：
-- 从手卡丢弃1张怪兽卡去墓地。选择自己场上1只比丢弃怪兽等级低的怪兽。选择的那只怪兽在这个回合可以攻击2次。
function c34187685.initial_effect(c)
	-- 从手卡丢弃1张怪兽卡去墓地。选择自己场上1只比丢弃怪兽等级低的怪兽。选择的那只怪兽在这个回合可以攻击2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetLabel(0)
	e1:SetCondition(c34187685.condition)
	e1:SetCost(c34187685.cost)
	e1:SetTarget(c34187685.target)
	e1:SetOperation(c34187685.activate)
	c:RegisterEffect(e1)
end
-- 发动条件定义：仅在当前回合玩家可以进入战斗阶段时才能发动（通常在主要阶段自由时点发动）。
function c34187685.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段，作为此魔法的发动条件。
	return Duel.IsAbleToEnterBP()
end
-- 代价处理：设置Label为1作为标记，表示代价阶段已通过；实际从手卡丢弃怪兽的操作在目标选择阶段完成。
function c34187685.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义可丢弃怪兽的筛选条件：必须是原等级大于1的怪兽卡，可以被丢弃且可以作为代价送去墓地，并且场上存在可选择的低等级表侧表示怪兽。
function c34187685.filter1(c,tp)
	local lv=c:GetOriginalLevel()
	return lv>1 and c:IsType(TYPE_MONSTER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
		-- 确认自己场上有1只满足filter2条件的表侧表示怪兽存在（等级低于丢弃怪兽且未受额外攻击次数效果影响），从而保证效果有合法对象。
		and Duel.IsExistingTarget(c34187685.filter2,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 定义选择对象的条件：对象必须表侧表示、等级低于丢弃怪兽的等级（即小于等于lv-1），且当前没有受到追加攻击次数效果的影响。
function c34187685.filter2(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv-1) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 目标选择处理：若是在连锁中确认对象，则验证对象是否在己方怪兽区且满足filter2；发动时先检查cost标记，若未通过则不能发动，若通过则从手牌选择1张怪兽卡丢弃，再选择1只比它等级低的表侧表示怪兽作为效果对象并登记。
function c34187685.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34187685.filter2(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在至少1张满足filter1条件的怪兽卡，用于判定效果能否发动。
		return Duel.IsExistingMatchingCard(c34187685.filter1,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 显示“请选择要丢弃的手牌”的提示信息，为接下来选择丢弃怪兽提供界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌中选出1张满足filter1条件的怪兽卡（即符合丢弃条件的怪兽）。
	local cg=Duel.SelectMatchingCard(tp,c34187685.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的手牌怪兽送去墓地，原因设为丢弃且作为代价。
	Duel.SendtoGrave(cg,REASON_DISCARD+REASON_COST)
	local lv=cg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 显示“请选择表侧表示的卡”的提示信息，为接下来选择场上对象怪兽提供界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且等级低于丢弃怪兽（lv-1以下）的怪兽作为这个效果的对象，并将它登记为当前连锁的目标。
	Duel.SelectTarget(tp,c34187685.filter2,tp,LOCATION_MZONE,0,1,1,nil,lv)
end
-- 效果处理：取得选择的目标怪兽，若其仍与效果关联，则给它赋予“本回合可以进行额外1次攻击”的持续效果，该效果在结束阶段或离场等标准时机重置。
function c34187685.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽，用于后续附加攻击次数效果。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 选择的那只怪兽在这个回合可以攻击2次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
