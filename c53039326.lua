--鋼核合成獣研究所
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡给1张「核成兽的钢核」对方观看。或者不给观看让这张卡破坏。每次场上存在的名字带有「核成」的怪兽在结束阶段时被破坏，那些怪兽的原本持有者可以从卡组把1只名字带有「核成」的怪兽加入手卡。
function c53039326.initial_effect(c)
	-- 记录此卡上记载着「核成兽的钢核」这张卡
	aux.AddCodeList(c,36623431)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己的结束阶段从手卡给1张「核成兽的钢核」对方观看。或者不给观看让这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53039326.mtcon)
	e2:SetOperation(c53039326.mtop)
	c:RegisterEffect(e2)
	-- 每次场上存在的名字带有「核成」的怪兽在结束阶段时被破坏，那些怪兽的原本持有者可以从卡组把1只名字带有「核成」的怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(53039326,2))  --"检索"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCode(EVENT_CUSTOM+53039326)
	e4:SetTarget(c53039326.target)
	e4:SetOperation(c53039326.operation)
	c:RegisterEffect(e4)
	if not c53039326.global_check then
		c53039326.global_check=true
		-- 注册一个用于检测怪兽被破坏的全局效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(c53039326.check)
		-- 将效果注册到玩家0（即所有玩家）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数，用于筛选手牌中未公开的「核成兽的钢核」
function c53039326.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 判断是否为自己的结束阶段
function c53039326.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 处理结束阶段时的效果，选择给对方观看或破坏场地卡
function c53039326.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示场地卡被选中的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 获取满足条件的「核成兽的钢核」手牌组
	local g=Duel.GetMatchingGroup(c53039326.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		-- 让玩家选择是否给对方观看「核成兽的钢核」或破坏场地卡
		sel=Duel.SelectOption(tp,aux.Stringid(53039326,0),aux.Stringid(53039326,1))  --"把1张「核成兽的钢核」对方观看/破坏「钢核合成兽研究所」"
	else
		-- 当没有「核成兽的钢核」时，只能选择破坏场地卡
		sel=Duel.SelectOption(tp,aux.Stringid(53039326,1))+1  --"破坏「钢核合成兽研究所」"
	end
	if sel==0 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local cg=g:Select(tp,1,1,nil)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,cg)
		-- 将自己的手牌洗切
		Duel.ShuffleHand(tp)
	else
		-- 破坏此场地卡
		Duel.Destroy(c,REASON_COST)
	end
end
-- 检测怪兽被破坏时触发的效果，判断是否为「核成」族并触发检索效果
function c53039326.check(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前阶段为结束阶段
	if Duel.GetCurrentPhase()~=PHASE_END then return end
	local tc=eg:GetFirst()
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	while tc do
		if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x1d) then
			if tc:GetOwner()==turnp then g1:AddCard(tc) else g2:AddCard(tc) end
		end
		tc=eg:GetNext()
	end
	-- 若本方场上的「核成」族怪兽被破坏，则触发检索效果
	if g1:GetCount()>0 then Duel.RaiseEvent(g1,EVENT_CUSTOM+53039326,re,r,rp,turnp,0) end
	-- 若对方场上的「核成」族怪兽被破坏，则触发检索效果
	if g2:GetCount()>0 then Duel.RaiseEvent(g2,EVENT_CUSTOM+53039326,re,r,rp,1-turnp,0) end
end
-- 过滤函数，用于筛选卡组中可加入手牌的「核成」族怪兽
function c53039326.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsAbleToHand()
end
-- 设置检索效果的目标和操作信息
function c53039326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c53039326.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组检索1张「核成」族怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作，选择并加入手牌
function c53039326.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c53039326.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
