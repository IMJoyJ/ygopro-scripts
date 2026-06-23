--海晶乙女瀑布
-- 效果：
-- 自己场上有连接3以上的「海晶少女」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：把自己场上的「海晶少女」连接怪兽任意数量直到下次的自己准备阶段除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升因为这张卡发动而除外的连接怪兽的连接标记合计×300。
function c27012990.initial_effect(c)
	-- ①：把自己场上的「海晶少女」连接怪兽任意数量直到下次的自己准备阶段除外，以场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
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
-- 设置效果发动的标签为1，表示可以发动效果。
function c27012990.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤满足条件的「海晶少女」连接怪兽，包括表侧表示、属于海晶少女卡组、连接怪兽类型、连接值大于等于1且可以作为费用除外。
function c27012990.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsLinkAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 检查所选的怪兽组中是否存在至少一张表侧表示的怪兽。
function c27012990.fselect(g,tp)
	-- 检查所选的怪兽组中是否存在至少一张表侧表示的怪兽。
	return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,g)
end
-- 设置效果目标，选择要除外的「海晶少女」连接怪兽，并设置效果目标为场上表侧表示的怪兽。
function c27012990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的「海晶少女」连接怪兽组。
	local g=Duel.GetMatchingGroup(c27012990.costfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return g:CheckSubGroup(c27012990.fselect,1,g:GetCount(),tp)
	end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c27012990.fselect,false,1,g:GetCount(),tp)
	local ct=rg:GetSum(Card.GetLink)
	e:SetLabel(ct)
	local tct=1
	-- 判断是否为当前回合玩家且处于准备阶段，若为真则tct设为2。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then tct=2 end
	local tc=rg:GetFirst()
	while tc do
		-- 将选中的怪兽以临时除外方式移除。
		if Duel.Remove(tc,0,REASON_COST+REASON_TEMPORARY)~=0 then
			tc:RegisterFlagEffect(27012990,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,tct)
		end
		tc=rg:GetNext()
	end
	rg:KeepAlive()
	-- 创建一个在准备阶段触发的效果，用于将除外的怪兽返回场上。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabelObject(rg)
	e1:SetCondition(c27012990.retcon)
	e1:SetOperation(c27012990.retop)
	-- 判断是否为当前回合玩家且处于准备阶段。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		-- 设置效果的值为当前回合数，用于判断是否需要返回怪兽。
		e1:SetValue(Duel.GetTurnCount())
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetValue(0)
	end
	-- 将准备阶段返回效果注册到场上。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 过滤拥有flag 27012990的怪兽，用于判断是否需要返回。
function c27012990.retfilter(c)
	return c:GetFlagEffect(27012990)~=0
end
-- 判断是否需要返回除外的怪兽，条件为当前回合玩家且回合数不等于设定值。
function c27012990.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者且回合数不等于设定值。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():IsExists(c27012990.retfilter,1,nil)
end
-- 将符合条件的除外怪兽返回场上。
function c27012990.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(c27012990.retfilter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将怪兽以原位置返回场上。
		Duel.ReturnToField(tc)
		tc=g:GetNext()
	end
end
-- 设置效果的发动，使目标怪兽攻击力上升。
function c27012990.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置攻击力提升效果，提升值为除外怪兽连接标记总和乘以300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤满足条件的「海晶少女」连接怪兽，包括表侧表示、属于海晶少女卡组、连接值大于等于3。
function c27012990.hcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsLinkAbove(3)
end
-- 判断是否满足手卡发动条件，即自己场上有连接3以上的「海晶少女」怪兽。
function c27012990.handcon(e)
	-- 检查自己场上是否存在至少一张连接值大于等于3的「海晶少女」连接怪兽。
	return Duel.IsExistingMatchingCard(c27012990.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
