--黒衣竜アルビオン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：这张卡在手卡·墓地存在的场合，把1只「阿不思的落胤」或1张「烙印」魔法·陷阱卡从手卡·卡组送去墓地才能发动。以那张卡从哪里送去墓地来对应的以下效果适用。
-- ●手卡：这张卡特殊召唤。
-- ●卡组：这张卡回到卡组最下面。从手卡回去的场合，再让自己抽1张。
function c25451383.initial_effect(c)
	-- 为这张卡注册一个效果：这张卡在场上·墓地存在时，卡名当作「阿不思的落胤」使用。
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在手卡·墓地存在的场合，把1只「阿不思的落胤」或1张「烙印」魔法·陷阱卡从手卡·卡组送去墓地才能发动。以那张卡从哪里送去墓地来对应的以下效果适用。●手卡：这张卡特殊召唤。●卡组：这张卡回到卡组最下面。从手卡回去的场合，再让自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25451383,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,25451383)
	e1:SetTarget(c25451383.target)
	e1:SetOperation(c25451383.operation)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：满足『卡名是「阿不思的落胤」或者是「烙印」魔法·陷阱卡』且可以作为代价送去墓地的卡。
function c25451383.costfilter(c)
	return (c:IsCode(68468459) or c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToGraveAsCost()
end
-- 效果发动条件和目标选择函数：检查是否满足发动条件（手卡/卡组存在可送墓的代价卡，且根据分支满足特殊召唤或回卡组的要求），若可行则让玩家从手卡和卡组中选择一张符合的卡送去墓地作为代价，并根据所选卡的位置与本卡当时所在位置设置对应的效果分支标签和操作信息。
function c25451383.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方手卡中是否存在1张满足代价筛选条件的卡（不包含本卡），作为『从手卡送墓→特殊召唤』分支的可行性条件。
	local b1=Duel.IsExistingMatchingCard(c25451383.costfilter,tp,LOCATION_HAND,0,1,c)
		-- 追加确认：我方主要怪兽区有空位，且本卡可以被特殊召唤（不检查召唤条件/苏生限制）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 检查我方卡组中是否存在1张满足代价筛选条件的卡，作为『从卡组送墓→回卡组』分支的可行性条件。
	local b2=Duel.IsExistingMatchingCard(c25451383.costfilter,tp,LOCATION_DECK,0,1,nil)
		-- 追加确认：本卡可以返回卡组，且（本卡在墓地时可直接返回，或本卡在手卡时我方可以抽卡），以满足『从手卡送墓时还要抽1张』的后续处理。
		and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or Duel.IsPlayerCanDraw(tp,1))
	if chk==0 then return b1 or b2 end
	local g=Group.CreateGroup()
	-- 取得手卡中所有满足代价筛选条件的卡（不包含本卡）的集合，供玩家选择送去墓地的卡。
	local g1=Duel.GetMatchingGroup(c25451383.costfilter,tp,LOCATION_HAND,0,c)
	-- 取得卡组中所有满足代价筛选条件的卡的集合，供玩家选择送去墓地的卡。
	local g2=Duel.GetMatchingGroup(c25451383.costfilter,tp,LOCATION_DECK,0,nil)
	if b1 then
		g:Merge(g1)
	end
	if b2 then
		g:Merge(g2)
	end
	-- 向选择玩家发送选择提示，提示内容为『请选择要送去墓地的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：本次效果处理包含将本卡特殊召唤，数量1，用于连锁响应检测（如星尘龙等）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
	if tc:IsLocation(LOCATION_DECK) and c:IsLocation(LOCATION_HAND) then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		-- 设置操作信息：本次效果处理包含将本卡返回卡组（从卡组送墓且本卡在手卡分支），数量1，用于连锁响应检测。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
		-- 设置操作信息：本次效果处理包含让tp抽1张卡（目标未定），用于连锁响应检测。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if tc:IsLocation(LOCATION_DECK) and c:IsLocation(LOCATION_GRAVE) then
		e:SetLabel(3)
		e:SetCategory(CATEGORY_TODECK)
		-- 设置操作信息：本次效果处理包含将本卡返回卡组（从卡组送墓且本卡在墓地分支），数量1，用于连锁响应检测。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	end
	-- 将玩家选择的卡片作为代价送去墓地（REASON_COST），完成效果发动代价。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 效果处理函数：根据发动时记录的标签执行对应分支——标签1：特殊召唤本卡；标签2：本卡返回卡组底端，若成功且本卡在卡组则再抽1张；标签3：本卡返回卡组底端。若本卡已与效果失去关联则终止处理。
function c25451383.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local label=e:GetLabel()
	if label==1 then
		-- 将本卡以表侧表示特殊召唤到tp场上（不检查召唤条件/苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if label==2 then
		-- 将本卡返回持有者卡组最底端；仅当实际返回成功（返回值≠0）且本卡仍位于卡组时，才继续执行后续抽卡处理。
		if Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
			-- 中断当前效果处理，使之后的抽卡处理与之前的回卡组处理分为不同批次，避免产生错误时点。
			Duel.BreakEffect()
			-- 让tp以效果原因（REASON_EFFECT）抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
	if label==3 then
		-- 将本卡返回持有者卡组最底端（对应从卡组送墓且本卡在墓地的分支）。
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
