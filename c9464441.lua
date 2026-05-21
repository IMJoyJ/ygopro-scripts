--魔救の奇跡－ドラガイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以让最多有那之中的岩石族怪兽数量的对方场上的卡回到手卡。翻开的卡用喜欢的顺序回到卡组下面。
-- ②：自己墓地有水属性怪兽存在，对方把魔法·陷阱卡的效果发动时才能发动。那个发动无效并破坏。
function c9464441.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以让最多有那之中的岩石族怪兽数量的对方场上的卡回到手卡。翻开的卡用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9464441,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9464441)
	e1:SetTarget(c9464441.thtg)
	e1:SetOperation(c9464441.thop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有水属性怪兽存在，对方把魔法·陷阱卡的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9464441,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9464442)
	e2:SetCondition(c9464441.discon)
	e2:SetTarget(c9464441.distg)
	e2:SetOperation(c9464441.disop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件与目标选择函数
function c9464441.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组上方的卡是否在5张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 效果①的处理函数（翻开卡组、弹回对方场上的卡、翻开的卡放回卡组最下方）
function c9464441.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组的卡不足5张则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 确认（翻开）自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	-- 若翻开的卡中有岩石族怪兽，且对方场上有可以回到手牌的卡，则玩家可以选择是否发动回手牌的效果
	if g:GetCount()>0 and g:FilterCount(Card.IsRace,nil,RACE_ROCK)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(9464441,2)) then  --"是否选卡回到手卡？"
		local ct=g:FilterCount(Card.IsRace,nil,RACE_ROCK)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择最多等同于翻开的岩石族怪兽数量的对方场上的卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
		-- 显式提示选中的卡片
		Duel.HintSelection(sg)
		-- 将选中的卡送回持有者手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
	if g:GetCount()>0 then
		-- 让玩家对翻开的卡进行排序
		Duel.SortDecktop(tp,tp,g:GetCount())
		for i=1,g:GetCount() do
			-- 获取卡组最上方的一张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到卡组最下方
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 效果②的发动条件检查函数
function c9464441.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发动的效果是否为魔法·陷阱卡的效果、该发动是否可以被无效，以及自己墓地是否存在水属性怪兽
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WATER)
end
-- 效果②的靶向与操作信息设置函数
function c9464441.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的处理函数（无效发动并破坏）
function c9464441.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该发动，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
