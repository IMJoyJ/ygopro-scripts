--森のメルフィーズ
-- 效果：
-- 2星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「童话动物」卡加入手卡。
-- ②：自己场上的其他的表侧表示的「童话动物」怪兽回到自己手卡的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不能攻击，效果无效化。
function c30439101.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤条件：等级2的怪兽2只作为超量素材（2星怪兽×2）。
	aux.AddXyzProcedure(c,nil,2,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1张「童话动物」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30439101,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,30439101)
	e1:SetCost(c30439101.thcost)
	e1:SetTarget(c30439101.thtg)
	e1:SetOperation(c30439101.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的其他的表侧表示的「童话动物」怪兽回到自己手卡的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽只要在场上表侧表示存在，不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30439101,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30439102)
	e2:SetCondition(c30439101.discon)
	e2:SetTarget(c30439101.distg)
	e2:SetOperation(c30439101.disop)
	c:RegisterEffect(e2)
end
-- ①效果的发动费用：取除这张卡的1个超量素材；chk==0时检查是否有素材可取。
function c30439101.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器：对象卡必须是「童话动物」卡且能够加入手卡。
function c30439101.thfilter(c)
	return c:IsSetCard(0x146) and c:IsAbleToHand()
end
-- ①效果的目标设定：确认卡组中存在符合条件的「童话动物」卡，并设置从卡组将1张加入手卡的操作信息。
function c30439101.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：己方卡组中是否存在至少1张满足thfilter的「童话动物」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c30439101.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果属于‘加入手卡’类别，预计从己方卡组将1张「童话动物」卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从己方卡组选择1张「童话动物」卡加入手卡，并向对方展示。
function c30439101.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足thfilter的「童话动物」卡。
	local g=Duel.SelectMatchingCard(tp,c30439101.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果触发过滤器：判断事件卡是否满足‘从自己场上表侧表示、控制者为自己的「童话动物」怪兽返回自己手卡’。
function c30439101.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x146) and c:IsControler(tp)
end
-- ②效果发动条件：本次加入手卡事件组中存在至少1张符合cfilter的己方「童话动物」怪兽。
function c30439101.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30439101.cfilter,1,nil,tp)
end
-- ②效果的目标选择：以对方场上1只表侧表示怪兽为对象，并设置无效化操作信息。
function c30439101.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 发动前检查：对方场上是否存在至少1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择无效对象提示：请选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：效果类别为‘无效化’，对象为g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果处理：对象怪兽在场上表侧表示期间不能攻击且效果无效化；并使与该怪兽相关的连锁无效。
function c30439101.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽（即第一个连锁对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽只要在场上表侧表示存在，不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使与对象怪兽相关的连锁无效化，并在该怪兽变里侧时重置此无效化状态。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽只要在场上表侧表示存在，效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 那只怪兽只要在场上表侧表示存在，效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
