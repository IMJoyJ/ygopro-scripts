--墓場からの誘い
-- 效果：
-- 对方卡组最上面1张卡表面向上放回卡组洗切。对方抽到那张卡时，那张卡直接送去墓地。
function c57270476.initial_effect(c)
	-- 开启全局卡组翻转检查标记（用于支持卡组中存在正面表示卡片的功能）
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- 对方卡组最上面1张卡表面向上放回卡组洗切。对方抽到那张卡时，那张卡直接送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c57270476.target)
	e1:SetOperation(c57270476.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与条件检查函数
function c57270476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否有1张以上的卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
-- 效果发动时的处理函数
function c57270476.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方卡组最上面1张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取对方卡组最上面1张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 洗切对方卡组
		Duel.ShuffleDeck(1-tp)
		tc:ReverseInDeck()
		-- 对方抽到那张卡时，那张卡直接送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DRAW)
		e1:SetOperation(c57270476.tgop)
		e1:SetReset(RESET_EVENT+0x1de0000)
		tc:RegisterEffect(e1)
	end
end
-- 抽到该卡时将其送去墓地的效果处理函数
function c57270476.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡因效果送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
