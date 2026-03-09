--森羅の蜜柑子 シトラ
-- 效果：
-- ①：场上的这张卡被对方破坏送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
-- ②：卡组的这张卡被效果翻开送去墓地的场合发动。自己场上的全部植物族怪兽的攻击力·守备力上升300。
function c47077318.initial_effect(c)
	-- 效果原文：①：场上的这张卡被对方破坏送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47077318,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c47077318.condition)
	e1:SetTarget(c47077318.target)
	e1:SetOperation(c47077318.operation)
	c:RegisterEffect(e1)
	-- 效果原文：②：卡组的这张卡被效果翻开送去墓地的场合发动。自己场上的全部植物族怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47077318,1))  --"攻守上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c47077318.tdcon)
	e2:SetOperation(c47077318.tdop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断是否满足效果发动条件，即此卡因对方破坏而送入墓地且之前在自己控制下。
function c47077318.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousControler(tp)
end
-- 规则层面：检查玩家是否可以翻开卡组最上方一张牌。
function c47077318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以翻开卡组最上方一张牌。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 规则层面：执行效果处理，翻开卡组最上方的牌并根据种族决定去向。
function c47077318.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查玩家是否可以翻开卡组最上方一张牌。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 规则层面：确认玩家卡组最上方的一张牌。
	Duel.ConfirmDecktop(tp,1)
	-- 规则层面：获取玩家卡组最上方的一张牌组成的Group。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 规则层面：禁止接下来的操作自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 规则层面：将翻开的牌送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 规则层面：将翻开的牌移回卡组底部。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 规则层面：判断是否满足效果发动条件，即此卡从卡组被翻开送入墓地。
function c47077318.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 规则层面：过滤出场上正面表示且为植物族的怪兽。
function c47077318.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 规则层面：为所有符合条件的场上植物族怪兽增加300攻击力和守备力。
function c47077318.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取场上所有正面表示且为植物族的怪兽组成的Group。
	local g=Duel.GetMatchingGroup(c47077318.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 规则层面：给目标怪兽增加300攻击力。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
