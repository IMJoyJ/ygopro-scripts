--次元合成師
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡除外，这张卡的攻击力直到回合结束时上升500。
-- ②：自己场上的这张卡被破坏送去墓地时，以除外的1只自己怪兽为对象才能发动。那只怪兽加入手卡。
function c36733451.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡除外，这张卡的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36733451,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c36733451.target)
	e1:SetOperation(c36733451.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上的这张卡被破坏送去墓地时，以除外的1只自己怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36733451,1))  --"选择除外的1张自己怪兽卡加入手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36733451.thcon)
	e2:SetTarget(c36733451.thtg)
	e2:SetOperation(c36733451.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与操作信息设定：检查自己卡组顶端是否有可被除外的卡；若可以发动，则设置除外卡组顶端1张卡的操作信息。
function c36733451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组最上方的1张卡。
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		return tc and tc:IsAbleToRemove()
	end
	-- 设置本次连锁的处理信息：计划除外1张自己卡组（顶端）的卡，用于连锁判定与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：将自己卡组最上面的卡除外；若这张卡仍表侧表示且与效果关联，则使其攻击力直到回合结束时上升500。
function c36733451.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组最上方的1张卡。
	local g=Duel.GetDecktopGroup(tp,1)
	-- 禁止下一次操作触发自动洗牌检查，因为从卡组顶端除外不需要洗切卡组。
	Duel.DisableShuffleCheck()
	-- 将卡组顶端的卡以表侧表示除外，除外原因为效果。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡被破坏并被送去墓地，且破坏前在场上且控制权为自己的场合才能发动。
function c36733451.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)>0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果取对象的过滤条件：除外区表侧表示的怪兽卡，并且能够加入手卡。
function c36733451.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果发动时的取对象处理：选择除外的1只自己怪兽为对象，并设置将卡加入手卡的操作信息。
function c36733451.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c36733451.filter(chkc) end
	-- 检查是否存在满足条件的对象（除外的表侧表示自己怪兽且能加入手卡）。
	if chk==0 then return Duel.IsExistingTarget(c36733451.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己除外区选择1张满足条件的怪兽卡作为效果对象。
	local g=Duel.SelectTarget(tp,c36733451.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置本次连锁的处理信息：将所选对象加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果的实际处理：将作为对象的怪兽加入手卡，并向对方确认。
function c36733451.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡（原因为效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
