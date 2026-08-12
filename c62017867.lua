--超重武者グロウ－V
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在，这张卡被送去墓地的场合才能发动。从卡组上面把5张卡确认，用喜欢的顺序回到卡组上面。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外才能发动。自己卡组最上面的卡翻开，那张卡是「超重武者」怪兽的场合加入手卡，那只攻击怪兽的攻击力变成0。不是的场合把翻开的卡送去墓地。
function c62017867.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在，这张卡被送去墓地的场合才能发动。从卡组上面把5张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c62017867.condition)
	e1:SetTarget(c62017867.target)
	e1:SetOperation(c62017867.operation)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外才能发动。自己卡组最上面的卡翻开，那张卡是「超重武者」怪兽的场合加入手卡，那只攻击怪兽的攻击力变成0。不是的场合把翻开的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c62017867.atkcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c62017867.atktg)
	e2:SetOperation(c62017867.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己墓地没有魔法·陷阱卡存在
function c62017867.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在魔法或陷阱卡
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动准备：检查自己卡组数量是否在5张以上
function c62017867.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组最上方的卡是否至少有5张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 效果①的效果处理：将自己卡组最上方的5张卡按喜欢的顺序放回卡组最上方
function c62017867.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家确认自己卡组最上方的5张卡并按喜欢的顺序放回卡组最上方
	Duel.SortDecktop(tp,tp,5)
end
-- 效果②的发动条件：对方怪兽直接攻击宣言时
function c62017867.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果②的发动准备：检查自己是否能将卡组最上方的卡送去墓地
function c62017867.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己是否能将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果②的效果处理：翻开卡组最上方的卡，是「超重武者」怪兽则加入手卡且攻击怪兽攻击力变0，否则送去墓地
function c62017867.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时不能将卡组最上方的卡送去墓地，则不处理效果
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认（翻开）自己卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 使接下来的操作不触发系统自动洗牌检测
	Duel.DisableShuffleCheck()
	-- 如果翻开的卡是「超重武者」卡片，且成功将其加入手卡
	if tc:IsSetCard(0x9a) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 获取当前进行攻击宣言的怪兽
		local at=Duel.GetAttacker()
		if at:IsFaceup() and at:IsRelateToBattle() then
			-- 那只攻击怪兽的攻击力变成0
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			at:RegisterEffect(e1)
		end
	else
		-- 将翻开的非「超重武者」卡片送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
