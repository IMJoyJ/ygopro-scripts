--森羅の蜜柑子 シトラ
-- 效果：
-- ①：场上的这张卡被对方破坏送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
-- ②：卡组的这张卡被效果翻开送去墓地的场合发动。自己场上的全部植物族怪兽的攻击力·守备力上升300。
function c47077318.initial_effect(c)
	-- ①：场上的这张卡被对方破坏送去墓地时才能发动。自己卡组最上面的卡翻开，那张卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
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
	-- ②：卡组的这张卡被效果翻开送去墓地的场合发动。自己场上的全部植物族怪兽的攻击力·守备力上升300。
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
-- 效果①的发动条件：这张卡在场上被对方破坏并送去墓地，且破坏前由自己控制。
function c47077318.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousControler(tp)
end
-- 效果①发动时的目标合法性检查：不取对象，仅需确认自己卡组顶端有1张卡可以送去墓地。
function c47077318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能将卡组最上方1张卡送去墓地（即卡组不为空且没有不能从卡组把卡送去墓地的限制）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果①处理：确认并翻开卡组最上方1张卡，若为植物族怪兽则将其送去墓地，否则放回卡组最下面。
function c47077318.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认：若此时不能将卡组最上方1张卡送去墓地，则效果处理终止。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 向双方玩家确认卡组最上方1张卡（翻开给双方确认）。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方1张卡作为对象组，用于后续判断与处理。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁止后续自动洗牌检查，因为将卡送去墓地或放回卡组底部时不需要洗切卡组。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡从卡组送去墓地，原因为“效果”和“翻开卡组”（森罗相关的翻开处理）。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 若翻开卡不是植物族怪兽，则将其放回卡组最下面。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 效果②的触发条件：这张卡之前位于卡组，且因效果被翻开（REASON_REVEAL）送去墓地。
function c47077318.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 筛选出我方场上表侧表示存在的植物族怪兽。
function c47077318.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果②处理：我方场上全部表侧表示植物族怪兽的攻击力·守备力各上升300。
function c47077318.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方场上全部表侧表示植物族怪兽的集合。
	local g=Duel.GetMatchingGroup(c47077318.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部植物族怪兽的攻击力·守备力上升300（此处为攻击力上升部分）。
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
