--キャッチ・コピー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的效果让对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。自己从卡组选1张卡，给双方确认加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
function c2971446.initial_effect(c)
	-- ①：对方的效果让对方用抽卡以外的方法从卡组把卡加入手卡的场合才能发动。自己从卡组选1张卡，给双方确认加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
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
-- 该过滤函数用于判断事件中加入手牌的卡是否是“对方因其效果从卡组加入手牌且并非抽卡”的卡：其控制者为对方、此前位于卡组、移动原因为效果且不是抽卡。
function c2971446.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_DRAW)
end
-- 发动条件：满足“对方的效果让对方用抽卡以外的方法从卡组把卡加入手卡”的场合，即事件组eg中存在至少一张符合条件的卡，且该效果的发动者是对方玩家（rp==1-tp）。
function c2971446.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2971446.cfilter,1,nil,1-tp) and rp==1-tp
end
-- 效果发动时的目标处理：确认自己卡组有至少1张可以加入手卡的卡（否则不能发动），并设置本次连锁的操作为“从卡组加入手卡”的分类信息。
function c2971446.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以被加入手卡的卡，作为效果发动的合法性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本效果会涉及“从卡组加入手卡”（CATEGORY_TOHAND），用于连锁响应与相关卡片的检测；目标卡在处理时确定，数量为1，对象为自己卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从自己卡组选择1张可以加入手卡的卡，将其加入手牌并向对方确认；若该卡因此加入手牌，则给自己设置一个直到回合结束的封印效果，禁止自己发动该卡及其同名卡的效果。
function c2971446.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组中选择1张可以加入手卡的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因（REASON_EFFECT）送去其持有者的手卡，即加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将选择并加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			-- 这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c2971446.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将禁止发动效果的永续效果注册给发动玩家（tp），持续到回合结束。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 作为EFFECT_CANNOT_ACTIVATE的Value判定函数：当对方发动的效果的处理卡（re:GetHandler()）的卡号等于e:GetLabel()所记录的卡号时返回true，即禁止发动该卡及其同名卡的效果。
function c2971446.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
