--霞の谷の巨神鳥
-- 效果：
-- 这张卡的效果在同一连锁上只能发动1次。
-- ①：魔法·陷阱·怪兽的效果发动时，以自己场上1张「霞之谷」卡为对象才能发动。那张自己的「霞之谷」卡回到持有者手卡，那个发动无效并破坏。
function c29587993.initial_effect(c)
	-- 创建效果对象并设置效果描述、分类、类型、代码、属性、适用范围、使用次数限制、发动条件、效果处理目标和效果处理操作
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
-- 判断效果发动时的条件：该怪兽未在战斗中被破坏且连锁可被无效
function c29587993.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 该怪兽未在战斗中被破坏且连锁可被无效
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 筛选场上自己正面表示存在的霞之谷卡
function c29587993.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x37) and c:IsAbleToHand()
end
-- 设置效果处理目标：选择场上自己1张霞之谷卡作为对象，设置将该卡送回手牌、使连锁无效、若效果对象可破坏则设置破坏效果
function c29587993.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c29587993.filter(chkc) end
	-- 检查是否有满足条件的霞之谷卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c29587993.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上自己1张霞之谷卡作为对象
	local g=Duel.SelectTarget(tp,c29587993.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置将选中的霞之谷卡送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置使连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果对象的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理操作：将选中的霞之谷卡送回手牌，若成功则使连锁无效并破坏效果对象
function c29587993.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 将对象卡送回手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	if not tc:IsLocation(LOCATION_HAND) then return end
	-- 使连锁无效并破坏效果对象
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏效果对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
