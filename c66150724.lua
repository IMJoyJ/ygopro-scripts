--ペンデュラムーン
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「灵摆」灵摆怪兽加入手卡。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组把持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的最多2只表侧表示的灵摆怪兽加入手卡。这个效果的发动后，直到回合结束时自己只要灵摆召唤不成功，不能把怪兽的效果发动，自己的灵摆区域的卡的效果无效化。
function c66150724.initial_effect(c)
	-- 为这张卡注册灵摆怪兽属性（灵摆召唤、作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「灵摆」灵摆怪兽加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66150724,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,66150724)
	e1:SetTarget(c66150724.thtg1)
	e1:SetOperation(c66150724.thop1)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从自己的额外卡组把持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的最多2只表侧表示的灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66150724,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66150725)
	e2:SetTarget(c66150724.thtg2)
	e2:SetOperation(c66150724.thop2)
	c:RegisterEffect(e2)
	if not c66150724.global_check then
		c66150724.global_check=true
		-- 直到回合结束时自己只要灵摆召唤不成功
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS_G_P)
		ge1:SetOperation(c66150724.checkop)
		-- 注册全局环境效果，用于监测玩家是否进行了灵摆召唤
		Duel.RegisterEffect(ge1,0)
	end
end
-- 灵摆召唤成功时的回调函数，用于给玩家注册已成功灵摆召唤的标记
function c66150724.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 给进行灵摆召唤的玩家注册一个表示本回合已成功进行过灵摆召唤的Flag
	Duel.RegisterFlagEffect(rp,66150724,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤额外卡组中表侧表示的「灵摆」灵摆怪兽
function c66150724.thfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf2) and c:IsAbleToHand()
end
-- 灵摆效果①的发动准备：检查额外卡组是否存在符合条件的卡，并设置加入手卡和破坏自身的操作信息
function c66150724.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在表侧表示的「灵摆」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66150724.thfilter1,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的效果处理：将额外卡组1只表侧表示的「灵摆」灵摆怪兽加入手卡，之后破坏自身
function c66150724.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组选择1只表侧表示的「灵摆」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c66150724.thfilter1,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	-- 将选择的怪兽加入手卡，并确认其已成功到达手卡
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		if not c:IsRelateToEffect(e) then return end
		-- 中断效果处理，使后续的破坏处理与加入手牌不视为同时进行
		Duel.BreakEffect()
		-- 破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤额外卡组中表侧表示、且等级介于自己灵摆区域两张卡的灵摆刻度之间的灵摆怪兽
function c66150724.thfilter2(c,lsc,rsc)
	if c:IsFacedown() or not c:IsType(TYPE_PENDULUM) then return false end
	local lv=c:GetLevel()
	return lv>lsc and lv<rsc and c:IsAbleToHand()
end
-- 怪兽效果①的发动准备：检查灵摆区域是否有2张卡，并计算刻度范围，检查额外卡组是否存在符合等级条件的怪兽，设置加入手卡的操作信息
function c66150724.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己左侧灵摆区域的卡
		local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		-- 获取自己右侧灵摆区域的卡
		local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if not lc or not rc then return false end
		local lsc=lc:GetLeftScale()
		local rsc=rc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		-- 检查额外卡组是否存在至少1只等级在两侧灵摆刻度之间且可加入手牌的表侧表示灵摆怪兽
		return Duel.IsExistingMatchingCard(c66150724.thfilter2,tp,LOCATION_EXTRA,0,1,nil,lsc,rsc)
	end
	-- 设置操作信息：从额外卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理：将最多2只符合等级条件的表侧表示灵摆怪兽加入手卡，并适用“直到回合结束时自己只要灵摆召唤不成功，不能发动怪兽效果且灵摆区域卡的效果无效化”的限制
function c66150724.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己左侧灵摆区域的卡
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取自己右侧灵摆区域的卡
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if lc and rc then
		local lsc=lc:GetLeftScale()
		local rsc=rc:GetRightScale()
		if lsc>rsc then lsc,rsc=rsc,lsc end
		-- 再次检查额外卡组是否存在符合等级条件的表侧表示灵摆怪兽
		if Duel.IsExistingMatchingCard(c66150724.thfilter2,tp,LOCATION_EXTRA,0,1,nil,lsc,rsc) then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从额外卡组选择最多2只符合等级条件的表侧表示灵摆怪兽
			local g=Duel.SelectMatchingCard(tp,c66150724.thfilter2,tp,LOCATION_EXTRA,0,1,2,nil,lsc,rsc)
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 重置玩家的灵摆召唤成功Flag（确保此效果发动后，必须在效果发动后进行灵摆召唤才算成功）
	Duel.ResetFlagEffect(tp,66150724)
	-- 不能把怪兽的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c66150724.discon)
	e1:SetValue(c66150724.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：限制玩家发动怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 自己的灵摆区域的卡的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_PZONE,0)
	e2:SetCondition(c66150724.discon)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：使自己灵摆区域的卡的效果无效化
	Duel.RegisterEffect(e2,tp)
	-- 自己的灵摆区域的卡的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c66150724.discon)
	e3:SetOperation(c66150724.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：在连锁处理时使自己灵摆区域的卡的效果无效
	Duel.RegisterEffect(e3,tp)
end
-- 限制发动效果的类型为怪兽效果
function c66150724.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 限制与无效化效果的适用条件：玩家本回合在效果发动后尚未成功进行过灵摆召唤
function c66150724.discon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查玩家是否未持有“本回合已成功进行过灵摆召唤”的Flag
	return Duel.GetFlagEffect(tp,66150724)==0
end
-- 连锁处理时的无效化操作：如果发动的是自己灵摆区域的卡的效果，则将其效果无效
function c66150724.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该连锁的效果控制者以及发动位置
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and p==tp and bit.band(loc,LOCATION_PZONE)~=0 then
		-- 无效该连锁的效果
		Duel.NegateEffect(ev)
	end
end
