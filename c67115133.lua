--絢嵐たる献詠
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只4星以下的「绚岚」怪兽加入手卡。
-- ●从自己的卡组·墓地把1张「旋风」加入手卡。
-- ②：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己的魔法与陷阱区域盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①和效果②。
function s.initial_effect(c)
	-- 记录这张卡上记载了卡名「旋风」。
	aux.AddCodeList(c,5318639)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMING_END_PHASE)
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
-- 过滤卡组中4星以下的「绚岚」怪兽。
function s.thfilter2(c)
	return c:IsSetCard(0x1d1) and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组或墓地中的「旋风」。
function s.thfilter(c)
	return c:IsCode(5318639) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查并让玩家选择要发动的效果分支，并注册对应的同名卡回合限制标识。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的4星以下「绚岚」怪兽。
	local b1=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查当前回合是否尚未选择过分支1（「绚岚」怪兽检索）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查卡组或墓地中是否存在可检索的「旋风」。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 检查当前回合是否尚未选择过分支2（「旋风」检索）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用的分支中选择一个发动。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"检索「绚岚」怪兽"
			{b2,aux.Stringid(id,3),2})  --"检索「旋风」"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 给玩家注册本回合已选择分支1的标识。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从卡组将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
			-- 给玩家注册本回合已选择分支2的标识。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从卡组或墓地将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- 效果①的分支处理函数，根据玩家的选择执行对应的检索效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足条件的「绚岚」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组或墓地选择1张「旋风」（受王家之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 检查这张卡是否因「旋风」的效果而被破坏。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(5318639)
end
-- 效果②的发动准备，检查自身是否可以盖放并设置操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：将墓地的这张卡移出墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的实际处理，将这张卡在自己的魔法与陷阱区域盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己的魔法与陷阱区域盖放。
		Duel.SSet(tp,c)
	end
end
