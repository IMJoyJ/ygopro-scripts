--ライトロード・マジシャン ライラ
-- 效果：
-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。自己场上的表侧攻击表示的这张卡变成守备表示，作为对象的对方的卡破坏。这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。
-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c22624373.initial_effect(c)
	-- 对应效果①：“以对方场上1张魔法·陷阱卡为对象才能发动。自己场上的表侧攻击表示的这张卡变成守备表示，作为对象的对方的卡破坏。这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。”
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
	-- 对应效果②：“自己结束阶段发动。从自己卡组上面把3张卡送去墓地。”
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
-- 效果①的发动条件：这张卡处于表侧攻击表示
function c22624373.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 筛选可作为对象的卡：魔法·陷阱卡
function c22624373.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动时点：确认对象合法、选择对方场上的1张魔法·陷阱卡，并设置破坏该卡的操作信息
function c22624373.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c22624373.filter(chkc) end
	-- 若未发动过（chk==0），检查对方场上是否存在至少1张满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c22624373.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡作为对象，并自动关联为该连锁的对象
	local g=Duel.SelectTarget(tp,c22624373.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将选择的1张卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①处理：这张卡仍与效果相关且仍为表侧攻击表示时，将其变为表侧守备表示，破坏对象卡，并给自己附加不能变更表示形式的限制效果
function c22624373.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将这张卡从表侧攻击表示变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			-- 以效果原因破坏对象卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
		-- 对应效果①的最后一句话：“这个效果的发动后，直到下次的自己回合的结束时这张卡不能把表示形式变更。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：必须是自己的结束阶段
function c22624373.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果持有者（即自己），确保只在自己结束阶段发动
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的发动时点：设置从卡组顶将3张卡送去墓地的操作信息
function c22624373.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：将持有者（自己）卡组最上方3张卡送去墓地，属于卡组送墓类别
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②处理：从自己卡组上面把3张卡送去墓地
function c22624373.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行：以效果原因将自己卡组最上方3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
