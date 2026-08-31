--新世廻
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「维萨斯-斯塔弗罗斯特」存在的场合，以场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。这个回合的结束阶段，那个持有者可以把和回去的怪兽是种族不同并是等级比那个等级·阶级·连接低的1只怪兽从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，「吠陀」怪兽特殊召唤的场合才能发动。这张卡加入手卡。
function c75728539.initial_effect(c)
	-- 注册关联卡名：维萨斯-斯塔弗罗斯特
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场上有「维萨斯-斯塔弗罗斯特」存在的场合，以场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。这个回合的结束阶段，那个持有者可以把和回去的怪兽是种族不同并是等级比那个等级·阶级·连接低的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75728539,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,75728539)
	e1:SetCondition(c75728539.condition)
	e1:SetTarget(c75728539.target)
	e1:SetOperation(c75728539.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，「吠陀」怪兽特殊召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75728539,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,75728540)
	e2:SetCondition(c75728539.thcon)
	e2:SetTarget(c75728539.thtg)
	e2:SetOperation(c75728539.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的「维萨斯-斯塔弗罗斯特」
function c75728539.cfilter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- 发动条件：场上有「维萨斯-斯塔弗罗斯特」存在
function c75728539.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」
	return Duel.IsExistingMatchingCard(c75728539.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤条件：表侧表示且可回到卡组的效果怪兽
function c75728539.filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsAbleToDeck()
end
-- 发动条件与选择场上效果怪兽为对象
function c75728539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c75728539.filter(chkc) end
	-- 检查场上是否存在可回到卡组的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c75728539.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择要回到卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1只效果怪兽为对象
	local g=Duel.SelectTarget(tp,c75728539.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：对象怪兽回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数
function c75728539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 对象怪兽回到卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		local op=tc:GetOwner()
		local race=tc:GetRace()
		local lv=tc:GetLevel()|tc:GetRank()|tc:GetLink()
		-- 这个回合的结束阶段，那个持有者可以把和回去的怪兽是种族不同并是等级比那个等级·阶级·连接低的1只怪兽从卡组加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c75728539.srcon)
		e1:SetOperation(c75728539.srop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabel(op,race,lv)
		-- 注册回合结束阶段的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：种族不同、等级更低且可加入手卡的怪兽
function c75728539.srfilter(c,race,lv,p)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(race) and c:IsLevelBelow(lv-1) and c:IsAbleToHand(p)
end
-- 结束阶段检索效果发动条件
function c75728539.srcon(e,tp,eg,ep,ev,re,r,rp)
	local op,race,lv=e:GetLabel()
	-- 检查卡组是否存在符合条件的怪兽
	return Duel.IsExistingMatchingCard(c75728539.srfilter,op,LOCATION_DECK,0,1,nil,race,lv,op)
end
-- 结束阶段检索效果处理函数
function c75728539.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示
	Duel.Hint(HINT_CARD,0,75728539)
	local op,race,lv=e:GetLabel()
	-- 持有者选择是否从卡组将怪兽加入手卡
	if Duel.SelectYesNo(op,aux.Stringid(75728539,2)) then  --"是否从卡组把怪兽加入手卡？"
		-- 提示选择要加入手卡的怪兽
		Duel.Hint(HINT_SELECTMSG,op,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(op,c75728539.srfilter,op,LOCATION_DECK,0,1,1,nil,race,lv,op)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入持有者手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT,op)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-op,g)
		end
	end
end
-- 过滤条件：表侧表示的「吠陀」怪兽
function c75728539.thfilter(c,tp)
	return c:IsSetCard(0x19a) and c:IsFaceup()
end
-- 「吠陀」怪兽特殊召唤成功时的发动条件
function c75728539.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c75728539.thfilter,1,nil,tp)
end
-- 自身加入手卡效果目标检查
function c75728539.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 自身加入手卡效果处理函数
function c75728539.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的自身加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
