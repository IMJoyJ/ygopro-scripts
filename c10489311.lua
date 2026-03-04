--ヒーロー・メダル
-- 效果：
-- 对方控制的卡的效果把盖放的这张卡破坏送去墓地时，这张卡加入卡组洗切。那之后，从自己卡组抽1张卡。
function c10489311.initial_effect(c)
	-- 对方控制的卡的效果把盖放的这张卡破坏送去墓地时，这张卡加入卡组洗切。那之后，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10489311,0))  --"返回卡组并抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c10489311.drcon)
	e1:SetTarget(c10489311.drtg)
	e1:SetOperation(c10489311.drop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断函数
function c10489311.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果的处理目标设定函数
function c10489311.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将自身送去卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置从自己卡组抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的处理执行函数
function c10489311.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否与效果相关联且成功送去卡组并洗切
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 将自己卡组进行洗切
		Duel.ShuffleDeck(tp)
		-- 从自己卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
