--死翼のフレスヴェイス
-- 效果：
-- 风属性怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方墓地没有怪兽存在的场合，这张卡的攻击力上升2400。
-- ②：自己·对方回合，以对方墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
function c49105782.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要至少2只风属性怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WIND),2)
	c:EnableReviveLimit()
	-- ①：对方墓地没有怪兽存在的场合，这张卡的攻击力上升2400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49105782.atkcon)
	e1:SetValue(2400)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以对方墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
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
-- 效果①的适用条件判定：检查对方墓地是否存在怪兽。
function c49105782.atkcon(e)
	-- 检查对方墓地（以效果持有者视角的对方区域）是否存在怪兽；若不存在则返回true，使攻击力上升条件成立。
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),0,LOCATION_GRAVE,1,nil,TYPE_MONSTER)
end
-- 效果②的取对象过滤：选择的对象必须是墓地中的怪兽，且可以返回卡组。
function c49105782.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动时目标处理：先确认可以选取对象，然后提示玩家选择，从对方墓地选择1只符合条件的怪兽作为对象，并登记回卡组的操作信息。
function c49105782.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c49105782.tdfilter(chkc) end
	-- 发动合法性检查：对方墓地是否存在1只满足过滤条件且能被选择为对象的怪兽，若存在则允许发动。
	if chk==0 then return Duel.IsExistingTarget(c49105782.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给当前玩家显示选择提示文字“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让当前玩家从对方墓地选择1只满足tdfilter条件的怪兽，并设为该连锁的对象。
	local g=Duel.SelectTarget(tp,c49105782.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 登记本次效果处理信息：将对象g返回卡组，数量为1，用于连锁判定及相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②处理时：取得对象，若对象仍与效果关联，则将其返回持有者卡组并洗牌。
function c49105782.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②所选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回持有者卡组并洗牌，处理原因为效果。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
