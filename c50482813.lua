--SR吹持童子
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把这张卡以外的自己场上的风属性怪兽数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：把墓地的这张卡除外，以自己场上1只3星以上的风属性怪兽为对象才能发动。那只怪兽的等级下降2星。
function c50482813.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把这张卡以外的自己场上的风属性怪兽数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50482813,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50482813)
	e1:SetTarget(c50482813.thtg)
	e1:SetOperation(c50482813.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只3星以上的风属性怪兽为对象才能发动。那只怪兽的等级下降2星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50482813,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,50482814)
	-- 设置效果②的发动代价为把墓地的此卡除外（通过 aux.bfgcost 函数实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c50482813.target)
	e3:SetOperation(c50482813.operation)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：筛选表侧表示且风属性的怪兽，用于统计自己场上符合条件的怪兽数量。
function c50482813.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果①的发动时机判定：计算自己场上此卡以外的风属性怪兽数量作为要翻开的卡数，并确认卡组数量足够且翻开的卡中至少1张能加入手卡。
function c50482813.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上表侧表示的风属性怪兽数量，且排除效果发动者自身（e:GetHandler()），作为从卡组翻开的张数。
	local ct=Duel.GetMatchingGroupCount(c50482813.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 检查自己卡组的卡数是否不少于要翻开的数量 ct。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
		-- 检查卡组最上方 ct 张卡中是否存在至少1张能够加入手卡的卡。
		and Duel.GetDecktopGroup(tp,ct):IsExists(Card.IsAbleToHand,1,nil) end
	-- 设置操作信息：标记本次效果包含从卡组加入手卡的处理，预计有1张卡加入手卡，供相关卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：重新统计翻开数，翻开卡组顶端相应数量的卡，玩家选择其中1张加入手卡（若可加入），其余卡按玩家指定的顺序放回卡组最下面。
function c50482813.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新统计自己场上除发动者以外的风属性怪兽数量，作为实际翻开的张数。
	local ct=Duel.GetMatchingGroupCount(c50482813.cfilter,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 确认翻开玩家卡组最上方的 ct 张卡（向双方公开）。
	Duel.ConfirmDecktop(tp,ct)
	-- 取得卡组最上方 ct 张卡作为组对象 g，用于后续的选卡和放回操作。
	local g=Duel.GetDecktopGroup(tp,ct)
	if #g>0 then
		-- 禁用自动洗切卡组检测，因为后续手动处理从卡组取卡和剩余卡回卡组底，避免系统自动洗切。
		Duel.DisableShuffleCheck()
		-- 弹出选择提示，让玩家从翻开卡中选1张要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			-- 将选择的卡因效果原因送去其持有者的手卡。
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,sc)
			-- 洗切自己的手卡，以反映加入手卡后的手牌顺序变化。
			Duel.ShuffleHand(tp)
		else
			-- 若所选卡不能加入手卡（如受“不能加入手卡”效果限制），则将其以规则原因送去墓地。
			Duel.SendtoGrave(sc,REASON_RULE)
		end
	end
	if #g>1 then
		-- 让玩家对剩余翻开卡进行排序，决定它们回到卡组底端的顺序。
		Duel.SortDecktop(tp,tp,#g-1)
		for i=1,#g-1 do
			-- 取得当前卡组最上方的一张卡（即玩家排在最前面的剩余卡）。
			local dg=Duel.GetDecktopGroup(tp,1)
			-- 将这张卡移动到卡组最下面，循环执行即可将所有剩余卡按玩家指定顺序放回卡组底端。
			Duel.MoveSequence(dg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 定义过滤函数：筛选表侧表示、等级3星以上且风属性的怪兽，作为效果②的对象候选。
function c50482813.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果②的发动条件判定与取对象流程：确认自己场上有满足条件的目标，选择1只作为效果对象。
function c50482813.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50482813.filter(chkc) end
	-- 确认自己场上是否存在至少1只符合条件的表侧表示3星以上风属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c50482813.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的表侧风属性怪兽作为效果对象，并将该卡登记为连锁处理时的对象。
	local g=Duel.SelectTarget(tp,c50482813.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果②的发动处理：取得对象并检查其合法性，若仍表侧表示且与效果关联，则通过注册一个临时效果使其等级下降2星。
function c50482813.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级下降2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
