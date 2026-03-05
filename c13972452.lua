--マジェスペクター・ストーム
-- 效果：
-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
function c13972452.initial_effect(c)
	-- ①：把自己场上1只魔法师族·风属性怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c13972452.cost)
	e1:SetTarget(c13972452.target)
	e1:SetOperation(c13972452.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为魔法师族且风属性的怪兽
function c13972452.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果的费用处理函数
function c13972452.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13972452.cfilter,1,nil) end
	-- 选择1只满足条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c13972452.cfilter,1,1,nil)
	-- 将选中的怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 效果的对象选择函数
function c13972452.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在可送回卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择对方场上1只可送回卡组的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时的操作信息，指定将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果的发动处理函数
function c13972452.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
