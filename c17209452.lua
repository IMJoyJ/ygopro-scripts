--キラーチューン・ロタリー
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只调整给对方观看才能发动。进行1只调整的召唤。
-- ②：这张卡作为同调素材送去墓地的场合，可以从以下效果选择1个发动。
-- ●从对方墓地让1张卡回到卡组最下面。
-- ●对方手卡全部确认。那之后，可以从卡组把1张「杀手级调整曲」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 为怪兽注册三个效果：e1是场上这张卡作为同调素材时手卡调整也能作为同调素材的永续效果；e2是①效果（展示手卡和1只调整后召唤调整）的起动效果；e3是②效果（作为同调素材送去墓地时选择1个效果发动）的诱发选发效果，并将e3存入s.killer_tune_be_material_effect。
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡和手卡1只调整给对方观看才能发动。进行1只调整的召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.sumcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材送去墓地的场合，可以从以下效果选择1个发动。●从对方墓地让1张卡回到卡组最下面。●对方手卡全部确认。那之后，可以从卡组把1张「杀手级调整曲」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"作为同调素材送去墓地"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
end
-- 同调素材过滤函数：当此卡在场上作为同调素材时，允许手卡中满足条件的调整（同调士类型）也作为同调素材。
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 该效果（手卡调整作为同调素材）的适用条件：这张卡位于主要怪兽区（场上）。
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 条件过滤：手卡中的调整且不是公开状态的卡，用于①展示手卡调整时选择对象。
function s.cfilter(c)
	return c:IsType(TYPE_TUNER) and not c:IsPublic()
end
-- ①的cost处理：从手卡选择1只未公开的调整，与手卡的这张卡一起展示给对方确认，然后洗切手卡。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost合法性检测：此卡在手卡且未公开，并且手卡存在其他满足条件的调整。
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 弹出选择提示，让玩家选择一张要展示给对方确认的手卡调整。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1张可展示的调整（排除自身）作为展示对象。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将手卡的这张卡和选择的调整一起展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 确认后洗切手卡，重置手卡顺序。
	Duel.ShuffleHand(tp)
end
-- 选择可通常召唤的调整：满足调整类型且当前可进行通常召唤（由IsSummonable(true,nil)判断，不检查通常召唤次数/祭品等条件）。
function s.sumfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSummonable(true,nil)
end
-- ①的发动目标检测：场上或手卡存在可以通常召唤的调整；若存在则设置本次操作信息为召唤。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：确认场上或手卡存在1只可以通常召唤的调整。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，标记本次连锁的效果处理将进行通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ①的效果处理：选1只可以通常召唤的调整，将其进行通常召唤（忽略每回合的通常召唤次数限制）。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要召唤的调整。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡或场上选择1只可以通常召唤的调整。
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤：将选择的调整召唤到场上，ignore_count=true表示不占用通常召唤次数，e=nil表示按一般通常召唤规则处理。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- ②的发动条件：这张卡作为同调素材被送去墓地且当前位于墓地。
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索过滤：卡组中的「杀手级调整曲」魔法·陷阱卡，且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②的发动目标处理：检测两个可选效果是否满足条件（对方墓地有可回卡组的卡/对方有手卡），让玩家选择发动哪一个，并根据选择设置对应的效果分类和操作信息。
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测对方墓地是否存在1张可以回到卡组的卡。
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
	-- 检测对方是否有手卡（手卡数量大于0）。
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if chk==0 then return b1 or b2 end
	-- 用选项选择函数让玩家在②的两个效果中选择1个发动。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"对方墓地让1张卡回到卡组最下面"
		{b2,aux.Stringid(id,3),2})  --"确认对方手卡"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
		end
		-- 若选择回卡组效果，设置操作信息：将对方墓地的1张卡返回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		end
	end
end
-- ②的效果处理：根据玩家选择的选项执行对应效果——选1时从对方墓地选1张卡放回卡组最下面；选2时确认对方手卡，并可选从卡组检索「杀手级调整曲」魔陷加入手卡，最后洗切对方手卡。
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 弹出选择提示，选择要返回对方卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从对方墓地选择1张可回卡组的卡（用NecroValleyFilter排除因王家长眠之谷效果不能移动的卡）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,0,LOCATION_GRAVE,1,1,nil)
		if #g>0 then
			-- 展示所选卡片的选中动画，并记录其为对象。
			Duel.HintSelection(g)
			-- 将选择的卡以效果原因送回持有者卡组最下面。
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取对方全部手卡。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g>0 then
			-- 向自己展示对方所有手卡。
			Duel.ConfirmCards(tp,g)
			-- 从卡组中检索所有符合条件的「杀手级调整曲」魔法·陷阱卡。
			local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 如果存在可检索的卡且玩家选择“是”，则继续检索处理；否则跳过。
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把魔法·陷阱卡加入手卡？"
				-- 中断当前效果链，使后续检索处理视为独立的效果处理，避免错过时点。
				Duel.BreakEffect()
				-- 弹出选择提示，选择要加入手卡的「杀手级调整曲」魔陷。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选择的卡加入持有者手卡（检索）。
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				-- 将加入手卡的那张卡展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,tg)
			end
			-- 因为确认过对方手卡，最后洗切对方手卡。
			Duel.ShuffleHand(1-tp)
		end
	end
end
