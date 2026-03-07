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
-- 初始化卡片效果，启用灵摆属性并允许在灵摆区放置指示物
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x6a,LOCATION_PZONE)
	-- 只要另一边的自己的灵摆区域有天使族怪兽卡存在，每次自己受到效果伤害，给这张卡放置1个响鸣指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- 对方场上的怪兽的攻击力下降自己场上的响鸣指示物数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	-- 这张卡在手卡存在的场合，从手卡丢弃1张其他卡才能发动。从卡组选1只「天使之声」，这张卡和那张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡和卡组的「天使之声」一起放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	-- 这张卡召唤·特殊召唤的回合的自己主要阶段，从自己墓地把1张「异响鸣」通常魔法·通常陷阱卡除外才能发动。那张魔法·陷阱卡发动时的受到伤害的选项的效果适用。
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
		-- 注册用于记录召唤和特殊召唤的全局效果，用于标记卡片是否在召唤或特殊召唤的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的处理函数为aux.sumreg，用于记录召唤或特殊召唤的卡片
		ge1:SetOperation(aux.sumreg)
		-- 将全局效果ge1注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将全局效果ge2注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge2,0)
	end
end
-- 定义过滤函数，用于判断灵摆区的卡片是否为天使族怪兽
function s.cfilter(c)
	return c:GetOriginalRace()&RACE_FAIRY>0 and c:GetOriginalType()&TYPE_MONSTER>0
end
-- 判断是否满足条件：另一边的自己的灵摆区域有天使族怪兽卡存在，且受到的是效果伤害且伤害来源是自己
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区是否存在至少1张天使族怪兽卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and r==REASON_EFFECT and ep==tp
end
-- 当满足条件时，给该卡添加1个响鸣指示物，若指示物数量达到3则触发自定义事件
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x6a,1)
	if c:GetCounter(0x6a)==3 then
		-- 触发自定义事件，用于提示玩家该卡已获得3个响鸣指示物
		Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,0)
	end
end
-- 计算攻击力下降值，为场上响鸣指示物数量乘以-100
function s.adval(e,c)
	-- 返回场上响鸣指示物数量乘以-100作为攻击力下降值
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x6a)*-100
end
-- 发动效果时，从手卡丢弃1张其他卡作为代价
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足丢弃条件：手卡中存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 执行丢弃操作，丢弃手卡中1张可丢弃的卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 定义过滤函数，用于选择卡组中可放置的「天使之声」
function s.filter(c)
	return c:IsCode(3048768) and not c:IsForbidden()
end
-- 判断是否满足放置条件：灵摆区两个位置都可用，且卡组中存在「天使之声」
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区两个位置是否都可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		-- 检查卡组中是否存在「天使之声」
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 判断是否满足放置条件：该卡与灵摆区两个位置都可用
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与效果相关
	if not (c:IsRelateToEffect(e) and Duel.CheckLocation(tp,LOCATION_PZONE,0)
		-- 检查灵摆区两个位置是否都可用
		and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张「天使之声」
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将该卡移动到自己的灵摆区
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 将选中的「天使之声」移动到自己的灵摆区
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断是否满足条件：该卡在召唤或特殊召唤的回合
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 定义过滤函数，用于选择墓地中可除外的「异响鸣」魔法或陷阱卡
function s.pfilter(c)
	local typ=c:GetType()
	return c:IsSetCard(0x1a3) and (typ==TYPE_SPELL or typ==TYPE_TRAP) and c:IsAbleToRemoveAsCost()
		and c:CheckActivateEffect(false,true,false)
end
-- 判断是否满足发动条件：已支付代价，且墓地中存在符合条件的卡
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查墓地中是否存在符合条件的「异响鸣」魔法或陷阱卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择1张符合条件的卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	e:SetLabelObject(te)
	-- 将选中的卡除外作为代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除操作信息，防止效果被响应
	Duel.ClearOperationInfo(0)
end
-- 执行选中的魔法或陷阱卡的效果
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp,2) end
end
