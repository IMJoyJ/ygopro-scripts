--迷犬メリー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的场合，可以从以下效果选择1个发动。
-- ●这张卡回到卡组最下面。
-- ●从卡组把1只「迷犬 小栗子」加入手卡，这张卡回到卡组最上面。
function c71583486.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，可以从以下效果选择1个发动。●这张卡回到卡组最下面。●从卡组把1只「迷犬 小栗子」加入手卡，这张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71583486,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,71583486)
	e1:SetTarget(c71583486.target)
	e1:SetOperation(c71583486.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「迷犬 小栗子」且能加入手牌的怪兽
function c71583486.thfilter(c)
	return c:IsCode(11548522) and c:IsAbleToHand()
end
-- 效果发动时的可行性检测与分支效果选择处理
function c71583486.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsAbleToDeck()
	-- 检查卡组中是否存在「迷犬 小栗子」且自身能回到卡组，作为分支2的可发动条件
	local b2=Duel.IsExistingMatchingCard(c71583486.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToDeck()
	if chk==0 then return b1 or b2 end
	local op=0
	-- 若两个分支效果均满足发动条件，则让玩家选择其中一个效果发动
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(71583486,1),aux.Stringid(71583486,2))  --"这张卡回到卡组最下面/从卡组把1只「迷犬 小栗子」加入手卡"
	-- 若仅满足分支1（回到卡组最下面）的条件，则只能选择分支1
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(71583486,1))  --"这张卡回到卡组最下面"
	-- 若仅满足分支2（检索并回到卡组最上面）的条件，则只能选择分支2
	else op=Duel.SelectOption(tp,aux.Stringid(71583486,2))+1 end  --"从卡组把1只「迷犬 小栗子」加入手卡"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TODECK)
		-- 设置连锁信息，表示该效果包含将自身送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
		-- 设置连锁信息，表示该效果包含将自身送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
		-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理的执行函数，根据玩家的选择执行对应的分支效果
function c71583486.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		-- 将这张卡送回持有者卡组的最下面
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足条件的「迷犬 小栗子」
		local g=Duel.SelectMatchingCard(tp,c71583486.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 若成功将选中的怪兽加入手牌，则执行后续处理
		if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
			-- 洗切自身卡组
			Duel.ShuffleDeck(tp)
			-- 将这张卡送回持有者卡组的最上面
			Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
