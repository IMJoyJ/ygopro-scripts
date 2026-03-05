--増幅する悪意
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方回合的准备阶段时自己墓地存在的「增幅的恶意」的数量的对方卡组最上面的卡送去墓地。
function c14255590.initial_effect(c)
	-- 效果原文内容：只要这张卡在场上表侧表示存在，对方回合的准备阶段时自己墓地存在的「增幅的恶意」的数量的对方卡组最上面的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14255590,0))  --"卡组送墓"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c14255590.discon)
	e1:SetTarget(c14255590.distg)
	e1:SetOperation(c14255590.disop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方回合
function c14255590.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前回合玩家不等于效果持有者玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 效果作用：设置连锁处理时的卡组送去墓地操作信息
function c14255590.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁处理时的目标为对方卡组最上面3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果作用：处理效果发动时的卡组送去墓地操作
function c14255590.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 效果作用：统计自己墓地存在的「增幅的恶意」数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,14255590)
	if ct>0 then
		-- 效果作用：将对方卡组最上面指定数量的卡送去墓地
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
