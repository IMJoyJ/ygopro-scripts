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
-- 初始化函数：为这张卡添加灵摆属性并允许在灵摆区放置响鸣指示物，注册灵摆区两个永续效果（受效果伤害放指示物、对方怪兽降攻）、手卡与怪兽区各一个起动效果，并全局登记「召唤·特殊召唤的回合」的标记。
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤以及作为灵摆卡放置到灵摆区域。
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x6a,LOCATION_PZONE)
	-- 灵摆①：只要另一边的自己的灵摆区域有天使族怪兽卡存在，每次自己受到效果伤害，给这张卡放置1个响鸣指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- 灵摆②：对方场上的怪兽的攻击力下降自己场上的响鸣指示物数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	-- 怪兽①（这个卡名的①的怪兽效果1回合只能使用1次）：这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「天使之声」，这张卡和那张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡和卡组的「天使之声」一起放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	-- 怪兽②（这个卡名的②的怪兽效果1回合只能使用1次）：这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的受到伤害的选项的效果适用。
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
		-- 对应原文：这张卡召唤·特殊召唤的回合；灵摆①：只要另一边的自己的灵摆区域有天使族怪兽卡存在，每次自己受到效果伤害，给这张卡放置1个响鸣指示物；灵摆②：对方场上的怪兽的攻击力下降自己场上的响鸣指示物数量×100；怪兽①：从手卡丢弃1张其他卡才能发动，从卡组选1只「天使之声」，这张卡和那张卡在自己的灵摆区域放置。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 使用aux.sumreg处理「这张卡召唤的回合」的判定，给这个回合召唤的这张卡打上标记（即使效果被复制也不生效）。
		ge1:SetOperation(aux.sumreg)
		-- 把「通常召唤成功时」触发的全局持续效果注册给全局环境。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 把克隆出的「特殊召唤成功时」触发的全局持续效果注册给全局环境。
		Duel.RegisterEffect(ge2,0)
	end
end
s.mentioned_counter={
	[0x6a]=true,
}
-- 过滤函数：原本的种族是天使族且原本的种类是怪兽的卡。
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 放置响鸣指示物的条件：另一边的自己的灵摆区域存在天使族怪兽卡，且自己受到的是效果伤害。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在这张卡以外的天使族怪兽卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and r==REASON_EFFECT and ep==tp
end
-- 处理：给这张卡放置1个响鸣指示物；若响鸣指示物数量达到3个，则触发一次自定义事件。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 当响鸣指示物达到3个时，以这张卡触发自定义事件39210885（供其他「异响鸣」相关卡响应的时点）。
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 永续数值函数：计算对方怪兽攻击力下降的数值。
function s.adval(e,c)
	-- 返回自己场上存在的响鸣指示物数量×-100的攻击力变化值。
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x6a)*-100
end
-- 发动代价：从手卡丢弃1张这张卡以外的其他卡。
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡是否存在这张卡以外可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 让玩家选择1张这张卡以外的手卡，并将其作为代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 过滤函数：卡号为3048768的「天使之声」，且未被禁止放置到场上的卡。
function s.filter(c)
	return c:IsCode(3048768) and not c:IsForbidden()
end
-- 目标检查：灵摆区域两个格子都可用，且卡组存在可以放置的「天使之声」。
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的左右两个格子是否都可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组是否存在满足条件的「天使之声」。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理开始：先确认这张卡仍与效果关联且灵摆区域两个格子可用，否则中断处理。
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与这个效果关联，且灵摆区域左侧格子可用，否则中断处理。
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 确认灵摆区域右侧格子也可用，否则中断处理。
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 向玩家提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1只满足条件的「天使之声」。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 把这张卡以表侧表示放置到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 把选出的「天使之声」以表侧表示放置到自己的灵摆区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 发动条件：这张卡是这个回合召唤·特殊召唤的（带有召唤回合的登记标记）。
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤函数：「异响鸣」系列的通常魔法·通常陷阱卡，可以作为代价除外，并且其发动时的效果可以被确认。
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- 目标检查：已确认支付代价，且自己墓地存在满足条件的可除外的「异响鸣」通常魔法·通常陷阱卡。
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己墓地是否存在满足条件的卡。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「异响鸣」通常魔法·通常陷阱卡。
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 把选出的卡以表侧表示除外作为发动代价。
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除连锁0的操作信息，使这次除外处理不会被对方响应。
	Duel.ClearOperationInfo(0)
end
-- 处理：取出保存的那张魔法·陷阱卡的效果，执行其「发动时的受到伤害的选项」对应的操作函数。
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,2) end
end
