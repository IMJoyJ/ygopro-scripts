--森羅の鎮神 オレイア
-- 效果：
-- 7星怪兽×2
-- 1回合1次，把自己的手卡·场上1只植物族怪兽送去墓地才能发动。把那个等级数量的卡从卡组上面确认，用喜欢的顺序回到卡组上面。此外，1回合1次，把这张卡1个超量素材取除才能发动。从自己卡组上面把最多3张卡翻开。那之中有植物族怪兽的场合，那些怪兽全部送去墓地，选最多有那个数量的这张卡以外的场上的卡回到手卡。剩下的卡用喜欢的顺序回到卡组下面。
function c95239444.initial_effect(c)
	-- 设置XYZ召唤手续：7星怪兽2只
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- 1回合1次，把自己的手卡·场上1只植物族怪兽送去墓地才能发动。把那个等级数量的卡从卡组上面确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95239444,0))  --"确认卡组"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c95239444.stcost)
	e1:SetOperation(c95239444.stop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把这张卡1个超量素材取除才能发动。从自己卡组上面把最多3张卡翻开。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95239444,1))  --"翻开卡组"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c95239444.cost)
	e2:SetTarget(c95239444.target)
	e2:SetOperation(c95239444.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡或场上表侧表示的、等级小于等于自己卡组卡片数量的、可以送去墓地的植物族怪兽
function c95239444.cfilter(c,lv)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(lv) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 第一个效果的发动代价：选择手卡或场上1只植物族怪兽送去墓地，并记录其等级
function c95239444.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	-- 检查是否存在可作为发动代价送去墓地的植物族怪兽（其等级不能超过卡组卡片数量）
	if chk==0 then return Duel.IsExistingMatchingCard(c95239444.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,ct) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡或场上1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c95239444.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,ct)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	-- 将实际送去墓地的怪兽的等级记录为效果标签值
	e:SetLabel(Duel.GetOperatedGroup():GetFirst():GetLevel())
end
-- 第一个效果的处理：将卡组上方对应等级数量的卡按喜欢的顺序放回卡组最上方
function c95239444.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家对卡组最上方对应等级数量的卡片进行排序
	Duel.SortDecktop(tp,tp,e:GetLabel())
end
-- 第二个效果的发动代价：取除这张卡的1个超量素材
function c95239444.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 第二个效果的发动准备：检查是否能从卡组送卡去墓地，且场上是否存在除这张卡以外可以返回手牌的卡
function c95239444.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组顶端将卡送去墓地（翻开卡组的前提条件）
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查场上是否存在至少1张这张卡以外可以返回手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
-- 第二个效果的处理：玩家宣言1到3的数字，翻开对应数量的卡，植物族送去墓地并弹回场上的卡，其余卡放回卡组最下方
function c95239444.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此时无法从卡组送卡去墓地，则效果不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取当前卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>3 then ct=3 end
	local t={}
	for i=1,ct do t[i]=i end
	-- 玩家宣言要翻开的卡片数量（最多为3且不超过卡组剩余卡数）
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 确认（翻开）卡组最上方对应数量的卡片
	Duel.ConfirmDecktop(tp,ac)
	-- 获取卡组最上方被翻开的卡片组
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	-- 暂时关闭卡组洗牌检查，防止后续操作自动洗牌
	Duel.DisableShuffleCheck()
	-- 如果翻开的卡片中有植物族怪兽，并且成功将它们送去墓地
	if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)~=0 then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择最多有送去墓地数量的、这张卡以外的场上的卡
		local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,sg:GetCount(),c)
		if tg:GetCount()>0 then
			-- 恢复卡组洗牌检查
			Duel.DisableShuffleCheck(false)
			-- 将选择的场上的卡送回持有者手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 对剩下未送去墓地的卡片进行排序
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 获取卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡片移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
