--海晶乙女瀑布
-- 效果：
-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：把自己场上的「海晶少女」连接怪兽任意数量直到下次的自己准备阶段除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的连接怪兽的连接标记合计×300。
function c27012990.initial_effect(c)
	-- ①：把自己场上的「海晶少女」连接怪兽任意数量直到下次的自己准备阶段除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的连接怪兽的连接标记合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果只能在伤害步骤中且伤害计算前发动（伤害计算时不能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c27012990.cost)
	e1:SetTarget(c27012990.target)
	e1:SetOperation(c27012990.activate)
	c:RegisterEffect(e1)
	-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27012990,0))  --"适用「海晶少女瀑布」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c27012990.handcon)
	c:RegisterEffect(e2)
end
-- 该cost实际不支付任何卡作为代价，仅设置标记e:SetLabel(1)供target的合法性判定使用，并返回true表示满足cost条件。
function c27012990.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 筛选可作为除外代价的卡：表侧表示、属于「海晶少女」系列、连接怪兽、连接标记在1以上，并且可以作为代价除外。
function c27012990.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsLinkAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 在选定的除外组g之外，场上仍存在至少1只表侧表示怪兽可以成为效果对象，以保证发动合法。
function c27012990.fselect(g,tp)
	-- 检查场上是否存在除g以外、可作为效果对象的表侧表示怪兽（即不是被选为代价除外的那些卡）。
	return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,g)
end
-- 发动时选择要除外的「海晶少女」连接怪兽（任意数量）并暂时除外，记录其连接标记合计，创建在下次己方准备阶段将其返回的效果；然后选择场上1只表侧表示怪兽作为攻击力上升的对象。
function c27012990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方怪兽区所有符合除外代价条件的「海晶少女」连接怪兽，作为可选择的除外候选集合。
	local g=Duel.GetMatchingGroup(c27012990.costfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return g:CheckSubGroup(c27012990.fselect,1,g:GetCount(),tp)
	end
	-- 给玩家弹出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c27012990.fselect,false,1,g:GetCount(),tp)
	local ct=rg:GetSum(Card.GetLink)
	e:SetLabel(ct)
	local tct=1
	-- 如果当前正是己方的准备阶段，则把标志持续回合数设为2，使除外卡在第二次准备阶段才返回（即下次己方准备阶段）；否则设为1。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then tct=2 end
	local tc=rg:GetFirst()
	while tc do
		-- 以『代价+暂时除外』的方式将选中的卡除外；若除外交际成功则继续处理。
		if Duel.Remove(tc,0,REASON_COST+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(27012990,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,tct)
		end
		tc=rg:GetNext()
	end
	rg:KeepAlive()
	-- 把自己场上的「海晶少女」连接怪兽任意数量直到下次的自己准备阶段除外，以场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabelObject(rg)
	e1:SetCondition(c27012990.retcon)
	e1:SetOperation(c27012990.retop)
	-- 判断当前是否为己方准备阶段，从而决定返回效果的持续参数。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		-- 记录当前回合数，用于避免在发动当回合（若为准备阶段）立即触发返回，确保到下一次己方准备阶段才触发。
		e1:SetValue(Duel.GetTurnCount())
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetValue(0)
	end
	-- 把返回效果注册到整个场地，使除外的卡在下次己方准备阶段自动返回。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象（该对象会被记录为连锁对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 返回筛选函数：判断卡是否带有本次除外标记（27012990），只处理本次效果除外的卡。
function c27012990.retfilter(c)
	return c:GetFlagEffect(27012990)~=0
end
-- 返回效果的触发条件：在己方准备阶段且不是发动当回合的准备阶段（若发动时正处于准备阶段则跳过），并且存在带有标记的除外卡。
function c27012990.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前不是己方准备阶段，或当前回合数等于记录的发动回合数（即发动当回合的准备阶段），则返回false，不触发返回。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():IsExists(c27012990.retfilter,1,nil)
end
-- 执行返回操作：将之前被暂时除外且带标记的「海晶少女」连接怪兽全部返回场上。
function c27012990.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(c27012990.retfilter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将单张暂时除外的卡以离场前的表示形式返回场上。
		Duel.ReturnToField(tc)
		tc=g:GetNext()
	end
end
-- 效果处理：若对象仍表侧且与发动效果关联，则使对象攻击力上升（除外卡的连接标记合计×300），直到回合结束。
function c27012990.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽（已在发动时选择）。
	local tc=Duel.GetFirstTarget()
	local ct=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的连接怪兽的连接标记合计×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 手卡发动条件的过滤器：卡需表侧表示、属于「海晶少女」系列、连接标记在3以上。
function c27012990.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 手卡发动的条件函数：自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡可以从手卡发动。
function c27012990.handcon(e)
	-- 检查己方场上是否存在至少1只表侧表示且连接标记3以上的「海晶少女」怪兽，作为手卡发动条件。
	return Duel.IsExistingMatchingCard(c27012990.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
