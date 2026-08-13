--霞の谷の巨神鳥
-- 效果：
-- 这张卡的效果在同一连锁上只能发动1次。
-- ①：魔法·陷阱·怪兽的效果发动时，以自己场上1张「霞之谷」卡为对象才能发动。那张自己的「霞之谷」卡回到持有者手卡，那个发动无效并破坏。
function c29587993.initial_effect(c)
	-- 这张卡的效果在同一连锁上只能发动1次。①：魔法·陷阱·怪兽的效果发动时，以自己场上1张「霞之谷」卡为对象才能发动。那张自己的「霞之谷」卡回到持有者手卡，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29587993,0))  --"效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c29587993.discon)
	e1:SetTarget(c29587993.distg)
	e1:SetOperation(c29587993.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：自身不在战斗破坏确定状态，且当前连锁上的效果发动能够被无效化时才可发动。
function c29587993.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真当且仅当巨神鸟未处于战斗破坏确定状态，且当前连锁中的效果发动能够被无效化（即满足发动时机）。
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 目标筛选条件：选择自己场上表侧表示、卡名含有「霞之谷」字段、且可以被返回手牌的卡。
function c29587993.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x37) and c:IsAbleToHand()
end
-- 发动时处理：检查合法性，让玩家选择自己场上1张符合条件的「霞之谷」卡作为对象，并设置回手牌、无效发动、破坏的操作信息。
function c29587993.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c29587993.filter(chkc) end
	-- 发动时非cost检查：确认自己场上是否存在至少1张符合条件的「霞之谷」表侧表示卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c29587993.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 弹出选择提示，要求玩家选择1张要返回手牌的「霞之谷」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1张符合条件的「霞之谷」卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c29587993.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向系统登记本次效果包含“使对象返回手牌”的处理，对象为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 向系统登记本次效果包含“无效那个发动”的处理，影响目标为被无效的连锁上的效果发动（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 当被无效的效果的发动者卡片可被破坏且仍与该效果关联时，向系统登记本次效果包含“破坏那张卡”的处理。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时：先将对象卡返回持有者手牌；若成功返回手牌且对方效果的发动被无效，则将被无效效果的那张卡破坏。
function c29587993.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 将对象卡返回其持有者的手牌。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	if not tc:IsLocation(LOCATION_HAND) then return end
	-- 判定该连锁上的发动是否被成功无效，且被无效的效果的发动者卡片是否仍与效果关联（未被离场等）；若均成立则继续处理后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效的那个效果的发动者卡片（eg 中的卡）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
