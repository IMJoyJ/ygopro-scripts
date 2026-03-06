--ライトロード・マジシャン ライラ
-- 效果：
-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。自己场上的表侧攻击表示的这张卡变成守备表示，作为对象的对方的卡破坏。这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。
-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c22624373.initial_effect(c)
	-- 效果原文内容：①：以对方场上1张魔法·陷阱卡为对象才能发动。自己场上的表侧攻击表示的这张卡变成守备表示，作为对象的对方的卡破坏。这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22624373,0))  --"破坏魔法陷阱"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c22624373.descon)
	e1:SetTarget(c22624373.destg)
	e1:SetOperation(c22624373.desop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetDescription(aux.Stringid(22624373,1))  --"从卡组送3张卡去墓地"
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c22624373.discon)
	e2:SetTarget(c22624373.distg)
	e2:SetOperation(c22624373.disop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断效果发动时，光道魔术师丽拉是否处于表侧攻击表示。
function c22624373.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 规则层面操作：过滤出魔法或陷阱类型的卡片。
function c22624373.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面操作：设置效果目标，选择对方场上的魔法或陷阱卡作为破坏对象。
function c22624373.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c22624373.filter(chkc) end
	-- 规则层面操作：检查是否满足选择目标的条件，即对方场上是否存在魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c22624373.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面操作：向玩家提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：选择对方场上的一张魔法或陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22624373.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 规则层面操作：设置效果处理信息，确定将要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面操作：处理效果的发动，将自身从表侧攻击表示变为表侧守备表示，并破坏对方的魔法或陷阱卡，同时设置自身在下次自己回合结束前不能改变表示形式。
function c22624373.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：获取当前连锁效果的目标卡片。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 规则层面操作：将自身从表侧攻击表示变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			-- 规则层面操作：以效果为原因破坏目标卡片。
			Duel.Destroy(tc,REASON_EFFECT)
		end
		-- 效果原文内容：这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		c:RegisterEffect(e1)
	end
end
-- 规则层面操作：判断是否为当前回合玩家，用于触发结束阶段效果。
function c22624373.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前玩家是否为回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 规则层面操作：设置结束阶段效果的处理信息，确定将要从卡组送入墓地的卡数。
function c22624373.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置效果处理信息，确定将要从卡组送入墓地的卡数为3张。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 规则层面操作：处理结束阶段效果，将自己卡组最上面的3张卡送去墓地。
function c22624373.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：将指定玩家卡组最上面的3张卡送去墓地。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
