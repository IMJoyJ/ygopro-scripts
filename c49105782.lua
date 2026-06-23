--死翼のフレスヴェイス
-- 效果：
-- 风属性怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方墓地没有怪兽存在的场合，这张卡的攻击力上升2400。
-- ②：自己·对方回合，以对方墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
function c49105782.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2只风属性的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WIND),2)
	c:EnableReviveLimit()
	-- 对方墓地没有怪兽存在的场合，这张卡的攻击力上升2400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49105782.atkcon)
	e1:SetValue(2400)
	c:RegisterEffect(e1)
	-- 自己·对方回合，以对方墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49105782,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49105782)
	e2:SetTarget(c49105782.tdtg)
	e2:SetOperation(c49105782.tdop)
	c:RegisterEffect(e2)
end
-- 判断对方墓地是否没有怪兽存在
function c49105782.atkcon(e)
	-- 检查对方墓地是否存在至少1只怪兽
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),0,LOCATION_GRAVE,1,nil,TYPE_MONSTER)
end
-- 过滤函数，用于筛选可以送回卡组的怪兽
function c49105782.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果的发动条件和目标选择逻辑，允许选择对方墓地的一只怪兽作为对象
function c49105782.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c49105782.tdfilter(chkc) end
	-- 检查是否满足选择目标的条件，即对方墓地存在至少1只怪兽
	if chk==0 then return Duel.IsExistingTarget(c49105782.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地的一只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c49105782.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理时的操作信息，指定将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 设置效果的发动后处理逻辑，将目标怪兽送回卡组
function c49105782.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以洗牌方式送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
