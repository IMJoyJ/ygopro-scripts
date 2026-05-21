--ハイドランダー・オービット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有怪兽4只以上存在，那些卡名全部不同的场合，把这张卡解放才能发动。把自己墓地的怪兽数量的卡从自己卡组上面翻开。怪兽2只以上被翻开，那些卡名全部不同的场合，那之内的1只加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
-- ②：把墓地的这张卡除外，以自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组最下面。
function c93953933.initial_effect(c)
	-- ①：自己墓地有怪兽4只以上存在，那些卡名全部不同的场合，把这张卡解放才能发动。把自己墓地的怪兽数量的卡从自己卡组上面翻开。怪兽2只以上被翻开，那些卡名全部不同的场合，那之内的1只加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93953933)
	e1:SetCondition(c93953933.thcon)
	e1:SetCost(c93953933.thcost)
	e1:SetTarget(c93953933.thtg)
	e1:SetOperation(c93953933.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只怪兽为对象才能发动。那只怪兽回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,93953934)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c93953933.tdtg)
	e2:SetOperation(c93953933.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己墓地有4只以上的怪兽存在，且卡名全部不同
function c93953933.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地的所有怪兽卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>=4 and g:GetClassCount(Card.GetCode)==g:GetCount()
end
-- 效果①的代价：解放自身
function c93953933.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果①的发动检测：确认卡组数量是否足够，并检测卡组顶端是否有可加入手牌的卡
function c93953933.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算自己墓地的怪兽数量
		local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
		-- 如果自己卡组的卡片数量小于自己墓地的怪兽数量，则不能发动
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		-- 获取自己卡组最上方等同于墓地怪兽数量的卡片组
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
end
-- 效果①的效果处理：翻开卡组顶端对应数量的卡，若翻开的怪兽有2只以上且卡名全部不同，则选1只加入手牌，其余卡按喜欢顺序放回卡组顶端
function c93953933.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己墓地的怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 确认（翻开）自己卡组最上方的对应数量的卡
	Duel.ConfirmDecktop(tp,ct)
	-- 获取被翻开的卡片组
	local dg=Duel.GetDecktopGroup(tp,ct)
	local g=dg:Filter(Card.IsType,nil,TYPE_MONSTER)
	if g:GetCount()>=2 and g:GetClassCount(Card.GetCode)==g:GetCount() then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 禁用接下来的洗牌检测，防止因卡片加入手牌而自动洗牌
		Duel.DisableShuffleCheck()
		if sg:GetFirst():IsAbleToHand() then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切手牌
			Duel.ShuffleHand(tp)
		else
			-- 若选中的卡无法加入手牌，则根据规则送去墓地
			Duel.SendtoGrave(sg,REASON_RULE)
		end
		-- 将剩下未加入手牌的卡按喜欢的顺序放回卡组最上方
		Duel.SortDecktop(tp,tp,dg:GetCount()-1)
	-- 若不满足加入手牌的条件，则将所有翻开的卡按喜欢的顺序放回卡组最上方
	else Duel.SortDecktop(tp,tp,dg:GetCount()) end
end
-- 过滤条件：自己墓地的怪兽且可以回到卡组
function c93953933.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的靶向：选择自己墓地1只怪兽作为对象，并设置操作信息为回卡组
function c93953933.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93953933.tdfilter(chkc) end
	-- 寻找自己墓地是否存在除这张卡以外的、可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(c93953933.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93953933.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽回到卡组最下面
function c93953933.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者卡组最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
