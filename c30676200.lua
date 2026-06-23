--灰滅せし都の英雄
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方的主要阶段，以场上1只炎族怪兽为对象才能发动。那只怪兽破坏。这个效果把「灭亡龙 威多释」破坏的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」在自己的场地区域表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤和破坏效果
function s.initial_effect(c)
	-- 记录该卡具有「灰灭之都 奥布西地暮」的卡名
	aux.AddCodeList(c,3055018)
	-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以场上1只炎族怪兽为对象才能发动。那只怪兽破坏。这个效果把「灭亡龙 威多释」破坏的场合，可以再从卡组把1张「灰灭之都 奥布西地暮」在自己的场地区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场地区域是否存在「灰灭之都 奥布西地暮」
function s.sprfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- 判断是否满足特殊召唤条件，即场地区域存在「灰灭之都 奥布西地暮」且有空位
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断是否有空位且场地区域存在「灰灭之都 奥布西地暮」
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断是否处于主要阶段
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数，用于判断是否为炎族怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO)
end
-- 设置破坏效果的目标选择逻辑
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
	-- 检查是否有符合条件的破坏目标
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一个炎族怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数，用于判断卡组中是否存在可放置的「灰灭之都 奥布西地暮」
function s.setfilter(c)
	return c:IsCode(3055018) and not c:IsForbidden()
end
-- 执行破坏效果的处理逻辑
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效且为怪兽并成功破坏
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)>0
		and tc:GetPreviousCodeOnField()==78783557
		-- 检查卡组中是否存在「灰灭之都 奥布西地暮」
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否发动放置场地效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否放置场地？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 从卡组选择一张「灰灭之都 奥布西地暮」
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		-- 获取当前玩家额外区域的场地卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将旧场地卡送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
		end
		-- 将选中的场地卡放置到场地区域
		Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
