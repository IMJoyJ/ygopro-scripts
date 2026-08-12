--強欲なポッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合发动。以下效果各适用。
-- ●把最多有对方场上的卡数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩余送去墓地。
-- ●把最多有从额外卡组特殊召唤的对方场上的怪兽数量的怪兽从自己的额外卡组送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检测与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽
	if Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA) then
		-- 若存在，则设置将额外卡组的卡送去墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 效果处理：翻开卡组并选择加入手卡，其余送去墓地
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的卡片数量
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	-- 检查玩家是否能将卡组顶端的卡送去墓地且卡组不为空
	if Duel.IsPlayerCanDiscardDeck(tp,1) and dc>0 then
		-- 获取对方场上的卡片数量
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
		if dc>ct then dc=ct end
		if dc>1 then
			local t={}
			for i=1,dc do table.insert(t,i) end
			-- 提示玩家选择要翻开的卡片数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))  --"请选择要翻开的卡的数量"
			-- 让玩家宣言要翻开的卡片数量
			dc=Duel.AnnounceNumber(tp,table.unpack(t))
		end
		-- 确认自己卡组最上方对应数量的卡
		Duel.ConfirmDecktop(tp,dc)
		-- 获取自己卡组最上方对应数量的卡片组
		local g=Duel.GetDecktopGroup(tp,dc)
		if #g>0 then
			-- 暂时关闭洗牌检测，防止在后续操作中自动洗卡组
			Duel.DisableShuffleCheck()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			-- 将选中的卡加入手牌，并判断是否成功
			if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
				-- 给对方玩家确认加入手牌的卡
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切自己的手牌
				Duel.ShuffleHand(tp)
				g:Sub(sg)
			end
			-- 将剩余翻开的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
	end
	-- 获取对方场上从额外卡组特殊召唤的怪兽数量
	local xc=Duel.GetMatchingGroupCount(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
	if xc>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从自己的额外卡组中选择最多等同于上述数量的怪兽
		local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,xc,nil)
		-- 将选中的额外卡组怪兽送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
