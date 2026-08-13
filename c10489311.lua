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
-- 判定触发条件：本卡因被破坏而送去墓地，且破坏原因来自对方控制的效果；该卡被送去墓地前由我方控制、在我方场上里侧表示存在。
function c10489311.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果发动时的目标处理：无需选择对象，确认可发动后登记本连锁将执行的‘回卡组’和‘抽卡’操作信息。
function c10489311.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记把此卡返回卡组的操作信息，对象确定为这张卡，数量为1，用于后续连锁判定（如对应回卡组效果）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记从自己卡组抽1张卡的操作信息；抽卡不取对象，targets为nil，target_param=1表示抽卡数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理阶段：若此卡仍与效果关联，则将其送回持有者卡组并洗切；如果成功送回卡组，则再从自己卡组抽1张。
function c10489311.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 条件判断：确认此卡仍与效果关联，且已被成功送回卡组（SendtoDeck返回值非0），且目前确实位于卡组，才执行洗牌与抽卡。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
		-- 洗切我方卡组。
		Duel.ShuffleDeck(tp)
		-- 我方从卡组抽1张卡（效果抽卡）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
