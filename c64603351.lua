--アトランティスの竜神－ダイダロス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「龙都 亚特兰蒂斯」或「海」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，卡名当作「海」使用。
-- ③：把自己场上最多3张表侧表示的「海」送去墓地才能发动。那个数量的除7星怪兽外的有「龙都 亚特兰蒂斯」的卡名记述的卡从卡组加入手卡。那之后，可以把场上1张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果：登记记载卡名、注册卡名变更效果，并注册①从手卡特殊召唤的起动效果和③检索卡组的起动效果
function s.initial_effect(c)
	-- 登记这张卡的效果文本上记载着「龙都 亚特兰蒂斯」（38391684）和「海」（22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- 注册卡名变更效果：这张卡在怪兽区域存在时，卡名当作「海」（22702055）使用
	aux.EnableChangeCode(c,22702055)
	-- ①：自己场上有「龙都 亚特兰蒂斯」或「海」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ③：把自己场上最多3张表侧表示的「海」送去墓地才能发动。那个数量的除7星怪兽外的有「龙都 亚特兰蒂斯」的卡名记述的卡从卡组加入手卡。那之后，可以把场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示的「龙都 亚特兰蒂斯」或「海」
function s.cfilter(c)
	return c:IsCode(38391684,22702055) and c:IsFaceup()
end
-- ①效果的发动条件：自己场上有表侧表示的「龙都 亚特兰蒂斯」或「海」，或者当前生效的场地卡为「海」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「龙都 亚特兰蒂斯」或「海」，或当前环境场地是否为「海」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- ①效果的目标设定：检查自己怪兽区域是否有空位且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能检测：确认自己怪兽区域有可用空格（且这张卡能被特殊召唤）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预定将这张卡（1张）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与连锁关联，则将其从手卡特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选自己场上表侧表示且能作为代价送去墓地的「海」
function s.costfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- ③效果的代价处理：统计卡组中可检索卡的数量（上限3张），令玩家选1至该数量张自己场上表侧表示的「海」送去墓地作为代价，并记录送去墓地的数量
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己卡组中满足检索条件的卡的数量
	local ct=Duel.GetMatchingGroupCount(s.thfilter,tp,LOCATION_DECK,0,nil)
	if ct>3 then ct=3 end
	-- 发动可能检测：卡组中至少有1张可检索的卡，且自己场上至少有1张可作为代价送去墓地的表侧表示的「海」
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1至ct张表侧表示的「海」作为代价
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 过滤函数：筛选卡组中有「龙都 亚特兰蒂斯」卡名记述、7星以外且能加入手卡的卡
function s.thfilter(c)
	-- 判定该卡是否记载着「龙都 亚特兰蒂斯」的卡名、不是7星怪兽且能加入手卡
	return aux.IsCodeListed(c,38391684) and not c:IsLevel(7) and c:IsAbleToHand()
end
-- ③效果的目标设定：确认卡组存在可检索的卡，并设置按代价数量从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能检测：确认自己卡组中至少有1张满足条件的可检索卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预定从卡组把等于代价数量（标签值）的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- ③效果的处理：从卡组选等于代价数量的有「龙都 亚特兰蒂斯」卡名记述的7星以外的卡加入手卡并给对方确认，那之后可以让玩家选场上1张卡送去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 若卡组中满足检索条件的卡不足代价数量，则中断处理
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,ct,nil) then
		return
	end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择等于代价数量（ct张）满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
	if #g>0 then
		-- 将选择的卡以效果处理加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡出示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
		-- 确认至少有1张卡已加入手卡，且双方场上存在可以送去墓地的卡
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否要将场上1张卡送去墓地
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选卡送去墓地？"
			-- 中断效果处理，使之后的送去墓地处理与加入手卡处理视为不同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 让玩家从双方场上选择1张可以送去墓地的卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 显示所选的卡被选定（送去墓地对象）的提示动画
			Duel.HintSelection(g)
			-- 将选择的场上1张卡以效果处理送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
