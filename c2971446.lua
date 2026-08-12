--キャッチ・コピー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的效果让对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。自己从卡组选1张卡，给双方确认加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
function c2971446.initial_effect(c)
	-- 创建一个永续效果，用于处理发动时的条件判断、目标选择和效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,2971446+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c2971446.condition)
	e1:SetTarget(c2971446.target)
	e1:SetOperation(c2971446.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为对方从卡组用效果加入手牌的卡
function c2971446.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_DRAW)
end
-- 效果发动条件，当对方用效果从卡组加入手牌时才能发动
function c2971446.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2971446.cfilter,1,nil,1-tp) and rp==1-tp
end
-- 效果目标设定，选择一张卡加入手牌
function c2971446.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查卡组中是否存在可加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要处理的卡是对方从卡组加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择卡组中的一张卡加入手牌并确认给对方
function c2971446.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张可加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			-- 创建一个场效果，禁止发动与该卡同名的卡的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c2971446.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将效果注册到场上
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制效果发动的函数，禁止发动与该卡同名的卡的效果
function c2971446.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
