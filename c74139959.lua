--星界樹イルミスティル
-- 效果：
-- 效果怪兽3只以上
-- ①：「星界树 伊尔明耀星树」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，每次对方在主要阶段把怪兽表侧表示特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
-- ③：自己·对方回合1次，支付1000的倍数的基本分才能发动（最多3000）。这张卡的攻击力上升支付的数值。
local s,id,o=GetID()
-- 初始化卡片效果，注册连接召唤手续、场上数量限制以及各项诱发和即时效果
function s.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽3只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	-- ②：只要这张卡在怪兽区域存在，每次对方在主要阶段把怪兽表侧表示特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.lpcon1)
	e1:SetOperation(s.lpop1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方在主要阶段把怪兽表侧表示特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方在主要阶段把怪兽表侧表示特殊召唤，自己回复那些怪兽的攻击力数值的基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lpcon2)
	e3:SetOperation(s.lpop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：自己·对方回合1次，支付1000的倍数的基本分才能发动（最多3000）。这张卡的攻击力上升支付的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"上升攻击力"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1)
	e4:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e4:SetCost(s.atkcost)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 过滤出由对方玩家表侧表示特殊召唤的怪兽
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsFaceup()
end
-- 检查是否在主要阶段且对方表侧表示特殊召唤了怪兽（非连锁处理中的特召）
function s.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and eg:IsExists(s.cfilter,1,nil,1-tp)
		and (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end
-- 计算对方特召怪兽的攻击力总和，并使自己回复对应数值的基本分
function s.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(s.cfilter,nil,1-tp)
	local rnum=lg:GetSum(Card.GetAttack)
	-- 使自己回复等同于特召怪兽攻击力总和的基本分
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 检查是否在主要阶段且对方在连锁处理中表侧表示特殊召唤了怪兽
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
		and eg:IsExists(s.cfilter,1,nil,1-tp)
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
-- 将连锁中特召的怪兽保存到卡片标签中，并给自身添加标记以备连锁结束后处理
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(s.cfilter,nil,1-tp)
	local g=e:GetLabelObject()
	if g==nil or #g==0 then
		lg:KeepAlive()
		e:SetLabelObject(lg)
	else
		g:Merge(lg)
	end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 检查自身是否带有在连锁中特召过怪兽的标记
function s.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 重置标记，获取保存在标签中的怪兽并计算其攻击力总和，清空临时卡组并回复对应数值的基本分
function s.lpop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	local lg=e:GetLabelObject():GetLabelObject()
	lg=lg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local rnum=lg:GetSum(Card.GetAttack)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
	lg:DeleteGroup()
	-- 使自己回复等同于特召怪兽攻击力总和的基本分
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 检查并支付1000的倍数的基本分（最多3000且不超过当前基本分）
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付至少1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000,true) end
	-- 获取玩家当前的基本分
	local lp=Duel.GetLP(tp)
	local t={}
	local f=math.floor((lp)/1000)
	local l=1
	while l<=f and l<=3 do
		t[l]=l*1000
		l=l+1
	end
	-- 提示玩家选择要支付的基本分数值
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要支付的数值"
	-- 让玩家宣言选择一个可支付的基本分数值
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(announce)
	-- 支付宣言的基本分数值
	Duel.PayLPCost(tp,announce,true)
end
-- 使这张卡的攻击力上升支付的基本分数值
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升支付的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
