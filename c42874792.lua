--ゼンマイラビット
-- 效果：
-- 选择自己场上1只名字带有「发条」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。此外，这个效果只在这张卡在场上表侧表示存在能使用1次。
function c42874792.initial_effect(c)
	-- 选择自己场上1只名字带有「发条」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。此外，这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42874792,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42874792.target)
	e1:SetOperation(c42874792.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片为表侧表示、卡名含有「发条」字段、且可以被除外。
function c42874792.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsAbleToRemove()
end
-- 效果发动时选择对象：确认存在合法对象，提示玩家选择自己场上1只表侧表示的名字带有「发条」的怪兽作为对象，并设置除外信息。
function c42874792.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c42874792.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在1只以上符合条件的发条怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c42874792.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让操作者从自己场上选择1只符合条件的发条怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c42874792.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息，标明本次操作会造成除外，对象为已选择的那只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时：取得对象怪兽，若仍与效果关联则将其暂时除外，并注册一个在计算好的“下次自己的准备阶段”返回场上的效果；返回效果由独立函数处理。
function c42874792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（即被除外的目标）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与效果关联且成功将其以暂时除外的方式除外；若成功则继续注册返回效果。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 选择的怪兽直到下次的自己的准备阶段时从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		-- 判断当前回合玩家是否就是效果发动者本人，以决定返回时机的回合计数方式。
		if Duel.GetTurnPlayer()==tp then
			-- 判断发动时是否处于抽卡阶段——若在本回合抽卡阶段发动，本回合的准备阶段尚未到来，返回时机可直接设为本回合。
			if Duel.GetCurrentPhase()==PHASE_DRAW then
				-- 在本回合抽卡阶段发动时，将返回时机设为当前回合数（即本回合的准备阶段）。
				e1:SetLabel(Duel.GetTurnCount())
			else
				-- 在自己回合的其他阶段发动时，本回合准备阶段已过，因此将返回时机设为当前回合数+2（下下个自己回合的准备阶段）。
				e1:SetLabel(Duel.GetTurnCount()+2)
			end
		else
			-- 在对方回合发动时，将返回时机设为当前回合数+1（下一个自己回合的准备阶段）。
			e1:SetLabel(Duel.GetTurnCount()+1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c42874792.retcon)
		e1:SetOperation(c42874792.retop)
		tc:RegisterEffect(e1)
	end
end
-- 返回效果的触发条件函数：当前回合数到达预设的标签值时触发。
function c42874792.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合数等于预设标签值时返回真，即到达指定回合的准备阶段。
	return Duel.GetTurnCount()==e:GetLabel()
end
-- 返回效果的处理：将被除外的怪兽返回场上，并重置该效果，确保只处理一次。
function c42874792.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的对象怪兽以离场前的表示形式返回场上。
	Duel.ReturnToField(e:GetHandler())
	e:Reset()
end
