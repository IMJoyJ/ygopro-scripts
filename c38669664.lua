--原質の炉心溶融
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把6张卡翻开，可以从那之中选1张「原质炉」卡加入手卡。剩余用喜欢的顺序回到卡组上面。那之后，可以把自己场上的3阶超量怪兽作为超量素材中的1张卡加入手卡。
-- ②：自己的超量怪兽把效果发动的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
local s,id,o=GetID()
-- 注册三个效果：e1为通常的魔陷发动效果，e2为①的起动检索效果，e3为②的诱发超量素材效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从自己卡组上面把6张卡翻开，可以从那之中选1张「原质炉」卡加入手卡。剩余用喜欢的顺序回到卡组上面。那之后，可以把自己场上的3阶超量怪兽作为超量素材中的1张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"翻开卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己的超量怪兽把效果发动的场合才能发动。把自己卡组最上面的卡作为自己场上1只「原质炉」超量怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"变成超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.ovcon)
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件检查与提示：若卡组数量超过5张（即可翻开6张）则允许发动，并提示对方玩家本卡将发动翻开卡组的效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性判定：自己卡组剩余数量超过5张（即至少有6张）时才可发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
	-- 向对方玩家提示已选择发动翻开卡组的①效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"翻开卡组"
end
-- 定义检索过滤条件：卡牌需为「原质炉」系列卡且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x160) and c:IsAbleToHand()
end
-- 定义筛选条件：表侧表示且阶级为3的超量怪兽，用于确认是否存在可回收素材的对象。
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsRank(3)
end
-- 处理①效果：翻开卡组顶最多6张卡，从中可选1张「原质炉」卡加入手卡，其余按玩家指定顺序放回卡组顶；之后可再选自己场上3阶超量怪兽的超量素材中的1张加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组当前的卡牌数量。
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dc==0 then return end
	if dc>6 then dc=6 end
	-- 让自己玩家确认卡组顶部的dc张卡。
	Duel.ConfirmDecktop(tp,dc)
	-- 获取卡组顶部dc张卡的卡片组对象，用于后续筛选与操作。
	local g=Duel.GetDecktopGroup(tp,dc)
	local sd=true
	-- 检查翻开的卡中是否存在可检索的「原质炉」卡，若存在则询问玩家是否选择其中1张加入手卡。
	if g:IsExists(s.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 向玩家显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,s.thfilter,1,1,nil)
		-- 禁用本次操作的自动洗牌检测，因为卡组顶部的卡将被精确放回而不需要洗切。
		Duel.DisableShuffleCheck()
		-- 将选择的「原质炉」卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己的手卡，以隐藏刚加入手卡的具体卡牌。
		Duel.ShuffleHand(tp)
		if dc>1 then
			-- 让玩家按任意顺序排列剩余的dc-1张卡，然后放回卡组顶，最上面为第一张。
			Duel.SortDecktop(tp,tp,dc-1)
		else
			sd=false
		end
	-- 当未选择将卡加入手卡时，将翻开的全部dc张卡由玩家排序后放回卡组顶。
	else Duel.SortDecktop(tp,tp,dc) end
	if sd then
		local rg=Group.CreateGroup()
		-- 获取自己场上所有表侧表示且阶级为3的超量怪兽，用于后续回收其超量素材。
		local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
		if xg:GetCount()<1 then return end
		-- 遍历每只符合条件的超量怪兽。
		for tc in aux.Next(xg) do
			local hg=tc:GetOverlayGroup()
			if hg:GetCount()>0 then
				rg:Merge(hg)
			end
		end
		-- 判断收集到的超量素材中是否有能加入手卡的卡，若有则询问玩家是否将其中1张加入手卡。
		if rg:FilterCount(Card.IsAbleToHand,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把超量素材加入手卡？"
			-- 中断当前效果处理，使后续加入手卡的处理与之前的检索处理作为不同时点处理，以免错过时点。
			Duel.BreakEffect()
			local thg=rg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			-- 将选中的超量素材以效果原因加入其持有者的手卡。
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			local sg=thg:Filter(Card.IsControler,nil,tp)
			if sg:GetCount()>0 then
				-- 将属于自己控制的超量素材卡展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切自己的手卡。
				Duel.ShuffleHand(tp)
			end
			local og=thg:Filter(Card.IsControler,nil,1-tp)
			if og:GetCount()>0 then
				-- 将属于对方玩家的超量素材卡展示给自己玩家确认。
				Duel.ConfirmCards(tp,og)
				-- 洗切对方玩家的手卡。
				Duel.ShuffleHand(1-tp)
			end
		end
	end
end
-- ②效果的发动条件：自己场上的超量怪兽发动效果时才能发动（效果来源需为自己、怪兽效果、且为超量怪兽）。
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsActiveType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ)
end
-- 定义可成为超量素材额外放置对象的卡：表侧表示且为「原质炉」系列的超量怪兽。
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x160)
end
-- ②效果的目标判定：确认自己场上存在可选的表侧「原质炉」超量怪兽，且卡组顶部有卡。
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在至少1只符合条件的「原质炉」超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己卡组至少有1张卡，满足从卡组顶取卡的条件。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 向对方玩家提示已选择发动将卡组顶卡变为超量素材的②效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"变成超量素材"
end
-- 处理②效果：将自己卡组最上面的1张卡叠放在自己场上1只符合条件的「原质炉」超量怪兽下作为超量素材；若无法叠放则将该卡送去墓地。
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组最上面的1张卡。
	local g=Duel.GetDecktopGroup(tp,1)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 禁用自动洗牌检测，卡组顶卡被精确取出用于叠放，不需要洗切。
		Duel.DisableShuffleCheck()
		-- 确认场上存在符合条件的「原质炉」超量怪兽，并且取出的卡可以叠放为超量素材。
		if Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsCanOverlay() then
			-- 向玩家显示选择提示：请选择表侧表示的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 从自己场上选择1只符合条件的「原质炉」超量怪兽作为放置素材的对象。
			local sg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 将取出的卡组顶卡叠放在所选择的超量怪兽下方，作为其超量素材。
			Duel.Overlay(sg:GetFirst(),Group.FromCards(tc))
		else
			-- 若场上没有合适的目标或取出的卡无法叠放，则将卡组顶的那张卡以规则原因送去墓地。
			Duel.SendtoGrave(g,REASON_RULE)
		end
	end
end
