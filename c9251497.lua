--金魚救い
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以对方墓地1只怪兽为对象才能发动。自己卡组最上面的卡翻开。翻开的卡是持有和作为对象的怪兽相同属性的怪兽的场合，翻开的卡加入手卡，作为对象的怪兽回到对方卡组。不是的场合，翻开的卡送去墓地，这张卡破坏。
function c9251497.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以对方墓地1只怪兽为对象才能发动。自己卡组最上面的卡翻开。翻开的卡是持有和作为对象的怪兽相同属性的怪兽的场合，翻开的卡加入手卡，作为对象的怪兽回到对方卡组。不是的场合，翻开的卡送去墓地，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,9251497)
	e2:SetTarget(c9251497.target)
	e2:SetOperation(c9251497.operation)
	c:RegisterEffect(e2)
end
-- 效果发动的对象选择与可行性检测
function c9251497.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsType(TYPE_MONSTER) end
	-- 检查对方墓地是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_GRAVE,1,nil,TYPE_MONSTER)
		-- 检查自己卡组是否有卡存在
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 提示玩家选择作为对象的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方墓地1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
end
-- 效果处理：翻开卡组最上方的卡，并根据其属性是否与对象怪兽相同进行分支处理
function c9251497.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组没有卡，则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	-- 翻开自己卡组最上面的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己卡组最上方翻开的卡片组
	local g=Duel.GetDecktopGroup(tp,1)
	if tc:IsRelateToEffect(e) then
		if g:GetFirst():GetAttribute()&tc:GetAttribute()~=0 then
			-- 将翻开的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将作为对象的怪兽回到对方卡组并洗牌
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		else
			-- 将翻开的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			-- 破坏这张卡
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
