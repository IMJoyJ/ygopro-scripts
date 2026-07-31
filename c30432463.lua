--悪魔の聲
-- 效果：
-- ←5 【灵摆】 5→
-- ①：只要另一边的自己的灵摆区域有天使族怪兽卡存在，每次自己受到效果伤害，给这张卡放置1个响鸣指示物。
-- ②：对方场上的怪兽的攻击力下降自己场上的响鸣指示物数量×100。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「天使之声」，这张卡和那张卡在自己的灵摆区域放置。
-- ②：这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的受到伤害的选项的效果适用。
local s,id,o=GetID()
-- 定义initial_effect函数，用于初始化卡片效果。
function s.initial_effect(c)
	-- 为灵摆怪兽c添加灵摆属性。
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x6a,LOCATION_PZONE)
	-- 注册一个场上持续生效的效果，当受到效果伤害时给这张卡放置响鸣指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- 注册一个场上效果，降低对方场上怪兽的攻击力。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	-- 注册一个起动效果，从手牌丢弃一张卡片来特殊召唤「天使之声」。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡和卡组的「天使之声」一起放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	-- 注册一个起动效果，在回合的主要阶段从墓地除外一张「异响鸣」魔法/陷阱卡并适用其效果。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.cpcon)
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 如果还没有注册过EVENT_SUMMON_SUCCESS和EVENT_SPSUMMON_SUCCESS事件，则注册它们以处理“这张卡召唤的回合”的限制。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 将aux.sumreg函数设置为EVENT_SUMMON_SUCCESS事件的操作。
		ge1:SetOperation(aux.sumreg)
		-- 将ge1效果注册到全局环境。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将克隆后的ge2效果注册到全局环境。
		Duel.RegisterEffect(ge2,0)
	end
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 定义一个过滤函数s.cfilter，用于筛选天使族怪兽。
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 定义条件函数s.ctcon，判断是否满足放置响鸣指示物的条件：对方场上有天使族怪兽且受到效果伤害。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方灵摆区域是否存在天使族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and r==REASON_EFFECT and ep==tp
end
-- 定义操作函数s.ctop，给这张卡添加响鸣指示物并触发自定义事件。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 触发一个自定义事件EVENT_CUSTOM+39210885。
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 定义计算攻击力下降值的函数s.adval。
function s.adval(e,c)
	-- 返回响鸣指示物的数量乘以-100，作为攻击力下降值。
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x6a)*-100
end
-- 定义起动效果的费用支付条件函数s.pzcost。
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以丢弃一张手牌。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 让玩家丢弃一张手牌。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 定义一个过滤函数s.filter，用于筛选卡组中的「天使之声」。
function s.filter(c)
	return c:IsCode(3048768) and not c:IsForbidden()
end
-- 定义起动效果的目标选择函数s.pztg。
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组中是否存在「天使之声」。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义起动效果的操作函数s.pzop，将这张卡和「天使之声」放置到灵摆区域。
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前效果是否有效以及灵摆区是否有空位
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 判断当前效果是否有效以及灵摆区是否有空位
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组中选择一张「天使之声」。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将这张卡移动到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 将选中的「天使之声」移动到自己的灵摆区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 定义条件函数s.cpcon，判断是否满足除外墓地魔法/陷阱卡的条件：这张卡在场上存在且被效果作用。
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义过滤函数s.pfilter，用于筛选可以作为除外cost的「异响鸣」魔法/陷阱卡。
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- 定义目标选择函数s.cptg，选择要除外的墓地魔法/陷阱卡。
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查是否满足除外条件以及是否存在符合条件的卡片
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择一张「异响鸣」魔法/陷阱卡。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 将选中的卡片从场上移除。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除OperationInfo，防止连锁发动效果被响应。
	Duel.ClearOperationInfo(0)
end
-- 定义操作函数s.cpop，执行除外的魔法/陷阱卡的效果。
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,2) end
end
