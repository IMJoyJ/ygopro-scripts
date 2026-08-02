--邪悪なる魔王－ゾーク
local s,id,o=GetID()
-- 注册效果：手卡丢弃检索效果，恶魔族被战破时的特召效果，掷骰子决定破坏或控制权效果。
function s.initial_effect(c)
	-- 把这张卡和1张手卡送去墓地才能发动。从卡组把1只8星的恶魔族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 自己场上的恶魔族怪兽被战斗破坏时才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 自己的主要阶段才能发动。掷1次骰子。1-4的场合，选对方场上1只怪兽，获得其控制权或将其破坏。5-6的场合，选场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.dctg)
	e3:SetOperation(s.dcop)
	c:RegisterEffect(e3)
end
-- 过滤条件：可以作为代价丢弃的卡。
function s.costfilter(c)
	return c:IsDiscardable()
end
-- 发动代价：选择自己手卡1张卡，与这张卡一起作为代价送去墓地。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除此卡外可以作为代价丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) and c:IsDiscardable() end
	-- 给己方发送提示信息：“请选择要丢弃的手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1张除此卡外的卡作为丢弃代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的手卡连同此卡一起作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：8星的恶魔族怪兽，并且能够加入手牌的卡。
function s.thfilter(c)
	return c:IsLevel(8) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- 效果对象设定：检查卡组是否有满足条件的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1只满足条件的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的卡加入手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1只满足条件的卡加入手牌，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给己方发送提示信息：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡加入己方手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：在场上表侧表示存在，原种族为恶魔族，且原控制者是己方的怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousRaceOnField()&RACE_FIEND==RACE_FIEND and c:IsPreviousControler(tp)
end
-- 发动条件：有满足过滤条件的怪兽被破坏，且这张卡自身不在那些被破坏的怪兽之中。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果对象设定：检查是否有足够的怪兽区域，以及此卡能否特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将这张卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：如果这张卡还在原处且不受王家长眠之谷影响，将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否还与连锁有联系且不受「王家长眠之谷」效果影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡在己方场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果对象设定：设置掷骰子的操作信息。
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置掷骰子的操作信息，预期结果为己方掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理：掷1次骰子，若结果为1-4则选对方怪兽夺取控制权或破坏，5-6则选场上1张卡破坏。
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让己方玩家掷1次骰子并记录结果。
	local dc=Duel.TossDice(tp,1)
	if dc>=1 and dc<=4 then
		-- 给己方发送提示信息：“请选择要操作的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家选择对方场上1只怪兽作为目标。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if g:GetCount()>0 then
			-- 为选中的怪兽显示被选为对象的动画。
			Duel.HintSelection(g)
			-- 如果选择的怪兽不能变更控制权，或者玩家选择不变更控制权（选择破坏）。
			if not tc:IsControlerCanBeChanged() or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 将选中的对方怪兽破坏。
				Duel.Destroy(tc,REASON_EFFECT)
			elseif tc:IsControlerCanBeChanged() then
				-- 获得选中对方怪兽的控制权。
				Duel.GetControl(tc,tp)
			end
		end
	elseif dc==5 or dc==6 then
		-- 获取场上所有卡的集合。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
		if g:GetCount()>0 then
			-- 给己方发送提示信息：“请选择要破坏的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 为选中的那张卡显示被选为对象的动画。
			Duel.HintSelection(sg)
			-- 破坏选中的那张卡。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
