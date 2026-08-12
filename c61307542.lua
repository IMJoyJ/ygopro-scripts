--バージェストマ・アノマロカリス
-- 效果：
-- 2星怪兽×3只以上
-- ①：这张卡不受其他怪兽的效果影响。
-- ②：1回合1次，陷阱卡从自己的魔法与陷阱区域送去墓地的场合才能发动。自己卡组最上面的卡翻开。那张卡是陷阱卡的场合，加入手卡。不是的场合，送去墓地。
-- ③：这张卡有陷阱卡在作为超量素材的场合，1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
function c61307542.initial_effect(c)
	-- 设置超量召唤手续：2星怪兽3只以上
	aux.AddXyzProcedure(c,nil,2,3,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡不受其他怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c61307542.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，陷阱卡从自己的魔法与陷阱区域送去墓地的场合才能发动。自己卡组最上面的卡翻开。那张卡是陷阱卡的场合，加入手卡。不是的场合，送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61307542,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(c61307542.condition)
	e2:SetTarget(c61307542.target)
	e2:SetOperation(c61307542.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡有陷阱卡在作为超量素材的场合，1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61307542,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c61307542.descon)
	e3:SetCost(c61307542.descost)
	e3:SetTarget(c61307542.destg)
	e3:SetOperation(c61307542.desop)
	c:RegisterEffect(e3)
end
-- 过滤不受影响的效果：其他玩家拥有的怪兽发动的效果
function c61307542.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
-- 过滤送去墓地的卡：自己魔法与陷阱区域（不含灵摆区域）的陷阱卡
function c61307542.cfilter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 判断是否满足发动条件：是否有符合条件的陷阱卡从自己的魔法与陷阱区域送去墓地
function c61307542.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c61307542.cfilter,1,nil,tp)
end
-- 效果②的发动准备与可行性检测
function c61307542.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的一张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 在发动时，检查玩家是否能将卡组顶端的卡送去墓地，且该卡是否能加入手卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and tc:IsAbleToHand() end
end
-- 效果②的效果处理
function c61307542.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能将卡组顶端的卡送去墓地，不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认（翻开）自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_TRAP) and tc:IsAbleToHand() then
		-- 使接下来的操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切手卡
		Duel.ShuffleHand(tp)
	else
		-- 使接下来的操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡作为被翻开的状态送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 判断是否满足发动条件：这张卡是否有陷阱卡在作为超量素材
function c61307542.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- 效果③的发动代价：取除这张卡的1个超量素材
function c61307542.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的发动准备，选择场上的一张卡作为对象
function c61307542.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动时，检查场上是否存在可以作为破坏对象的目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的一张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“破坏选中的卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的效果处理
function c61307542.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
