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
-- 检查卡组最上方的卡是否可以除外
function c36733451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家卡组最上方的1张卡
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		return tc and tc:IsAbleToRemove()
	end
	-- 设置连锁操作信息为除外卡组最上方的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 将卡组最上方的卡除外，并使自身攻击力上升500
function c36733451.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 禁止接下来的除外操作检测洗牌
	Duel.DisableShuffleCheck()
	-- 将卡组最上方的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- 判断效果是否因破坏而触发且该卡之前在场上且为玩家控制
function c36733451.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)>0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤函数：筛选正面表示的怪兽卡且能加入手牌
function c36733451.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置选择目标为除外区的1只自己怪兽卡
function c36733451.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c36733451.filter(chkc) end
	-- 检查是否存在符合条件的除外区怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c36733451.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标为除外区的1只自己怪兽卡
	local g=Duel.SelectTarget(tp,c36733451.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁操作信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 将选择的除外怪兽卡加入手牌并确认给对手
function c36733451.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对手确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
