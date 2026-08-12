--機怪神エクスクローラー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。那个发动无效并破坏。
-- ②：只要反转过的这张卡在怪兽区域存在，对方场上的怪兽发动的效果无效化。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。和这张卡是原本的种族·属性不同的1只9星怪兽从卡组加入手卡。
function c62587693.initial_effect(c)
	-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62587693,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c62587693.condition)
	e1:SetCost(c62587693.cost)
	e1:SetTarget(c62587693.target)
	e1:SetOperation(c62587693.operation)
	c:RegisterEffect(e1)
	-- ②：只要反转过的这张卡在怪兽区域存在，对方场上的怪兽发动的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c62587693.flipop)
	c:RegisterEffect(e2)
	-- ②：只要反转过的这张卡在怪兽区域存在，对方场上的怪兽发动的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c62587693.discon)
	e3:SetOperation(c62587693.disop)
	-- 在全局环境注册该无效化效果
	Duel.RegisterEffect(e3,0)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。和这张卡是原本的种族·属性不同的1只9星怪兽从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62587693,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,62587693)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c62587693.thcon)
	e4:SetTarget(c62587693.thtg)
	e4:SetOperation(c62587693.thop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：对方发动了以里侧表示的自身为对象的效果
function c62587693.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(e:GetHandler()) and e:GetHandler():IsFacedown()
end
-- 效果①的Cost：将自身变为表侧守备表示
function c62587693.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将自身变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 效果①的Target：设置无效与破坏的操作信息
function c62587693.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为“破坏”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的Operation：使发动无效并破坏该卡
function c62587693.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且该卡在场上/与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 反转时的处理：给自身注册已反转的标记
function c62587693.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(62587693,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤条件：表侧表示、具有已反转标记、未被战斗破坏且未被无效的怪兽
function c62587693.disfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(62587693)>0 and not c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsDisabled()
end
-- 效果②的无效化条件：对方场上的怪兽在怪兽区域发动效果，且我方场上存在已反转的这张卡
function c62587693.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果的玩家以及发动位置
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
		-- 检查对方（即这张卡的控制者）场上是否存在满足已反转条件的“机怪神”
		and Duel.IsExistingMatchingCard(c62587693.disfilter,p,0,LOCATION_MZONE,1,nil)
end
-- 效果②的无效化处理
function c62587693.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 效果③的发动条件：场上的这张卡被战斗或效果破坏
function c62587693.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中原本种族和属性与这张卡不同、可以加入手牌的9星怪兽
function c62587693.thfilter(c,ec)
	return c:IsLevel(9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and not c:IsRace(ec:GetRace()) and not c:IsAttribute(ec:GetAttribute())
end
-- 效果③的Target：检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息
function c62587693.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在原本种族·属性与自身不同的9星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62587693.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
	-- 设置当前连锁的操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的Operation：从卡组将符合条件的1只9星怪兽加入手牌
function c62587693.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c62587693.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
