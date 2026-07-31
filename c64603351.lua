--アトランティスの竜神－ダイダロス
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片、卡名规则当作「海」、手牌特召效果及送墓「海」检索并送墓场上卡效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「海龙神」与「海」
	aux.AddCodeList(c,38391684,22702055)
	-- 注册规则卡名变更：卡名在规则上当作「海」使用
	aux.EnableChangeCode(c,22702055)
	-- ①：场上有「海龙神」或者「海」存在的场合才能发动。手牌的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上最多3张表侧表示的「海」送去墓地才能发动。把最多有送去墓地数量的除7星以外的卡名有「海龙神」记载的卡从卡组加入手牌。那之后，可以把场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特召发动条件过滤：场上表侧表示存在的「海龙神」或「海」
function s.cfilter(c)
	return c:IsCode(38391684,22702055) and c:IsFaceup()
end
-- 手牌特召发动条件：场上或场地环境下存在「海龙神」或「海」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「海龙神」/「海」或当前场地环境为「海」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- 手牌特召发动检查：怪兽区域有空位且自身可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手牌特召效果处理：将手牌的此卡表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- Cost过滤条件：自己场上表侧表示的「海」
function s.costfilter(c)
	return c:IsCode(22702055) and c:IsAbleToGraveAsCost() and c:IsFaceup()
end
-- 检索效果Cost：根据卡组符合条件卡片数量选择最多3张表侧表示的「海」送去墓地，并记录数量
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算卡组中满足条件的卡片总数
	local ct=Duel.GetMatchingGroupCount(s.thfilter,tp,LOCATION_DECK,0,nil)
	if ct>3 then ct=3 end
	-- Cost检查：卡组存在目标卡且场上存在可送去墓地的「海」
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1~ct张表侧表示的「海」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 将选中的「海」作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 检索过滤条件：卡名记述「海龙神」、非7星且可加入手牌的卡
function s.thfilter(c)
	-- 检查卡片是否记述「海龙神」、等级不为7且可加入手牌
	return aux.IsCodeListed(c,38391684) and not c:IsLevel(7) and c:IsAbleToHand()
end
-- 检索效果准备：设置从卡组检索卡片的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索与Cost送墓数量相同的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel(),tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组把对应数量的卡加入手牌并确认，随后可选择将场上1张卡送去墓地
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 检查卡组中符合条件的卡片数量是否不低于记录数量
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,ct,nil) then
		return
	end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择对应数量满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查是否有卡成功加入手牌且场上存在可送去墓地的卡
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否将场上1张卡送去墓地
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 连接效果块（分隔加入手牌与送去墓地的操作）
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从场上选择1张可送去墓地的卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			-- 高亮显示选择的目标卡片
			Duel.HintSelection(g)
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
