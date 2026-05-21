--絢嵐たる顕現
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只「绚岚」怪兽送去墓地。
-- ●从自己的卡组·墓地把1张「旋风」加入手卡。
-- ②：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己的魔法与陷阱区域盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时选择1个效果适用）和②效果（被「旋风」效果破坏时在魔陷区盖放）。
function s.initial_effect(c)
	-- 将卡片密码为5318639（旋风）的卡加入此卡的关联卡片列表中。
	aux.AddCodeList(c,5318639)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可以送去墓地的「绚岚」怪兽。
function s.tgfilter(c)
	return c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤条件：卡组或墓地中可以加入手牌的「旋风」。
function s.thfilter(c)
	return c:IsCode(5318639) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target），检查并让玩家选择要发动的分支效果，并根据选择注册对应的同名卡回合一次限制及设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的「绚岚」怪兽。
	local b1=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且（在非检查发动Cost或实际发动时）该分支效果在本回合尚未被选择过。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查卡组或墓地中是否存在可以加入手牌的「旋风」。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 并且（在非检查发动Cost或实际发动时）该分支效果在本回合尚未被选择过。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的分支效果中选择一个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"送墓「绚岚」怪兽"
			{b2,aux.Stringid(id,3),2})  --"检索「旋风」"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
			-- 给玩家注册全局标识，限制该分支效果本回合不能再次选择。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从卡组将1张卡送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 给玩家注册全局标识，限制该分支效果本回合不能再次选择。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从卡组或墓地将1张卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- ①效果的效果处理（Operation），根据玩家选择的分支效果，执行对应的送墓或检索处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1张满足条件的「绚岚」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡因效果送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组或墓地选择1张满足条件且不受王家之谷影响的「旋风」。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡因效果加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的发动条件：此卡因效果被破坏，且该效果的来源是「旋风」。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(5318639)
end
-- ②效果的发动准备（Target），检查此卡是否可以盖放，并设置操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：1张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的效果处理（Operation），将此卡在自己的魔法与陷阱区域盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关，且不受王家之谷影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡在自己的魔法与陷阱区域盖放。
		Duel.SSet(tp,c)
	end
end
