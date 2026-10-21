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
-- 效果①的发动目标及合法性检测
function c36733451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组最上方的1张卡
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		return tc and tc:IsAbleToRemove()
	end
	-- 设置操作信息：从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的操作：除外卡组最上方的卡，自身攻击力直到回合结束时上升500
function c36733451.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if not tc or not tc:IsAbleToRemove() then return end
	-- 使接下来的卡组操作不执行洗牌检测
	Duel.DisableShuffleCheck()
	-- 将卡组顶端的卡表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：自己场上的这张卡被破坏
function c36733451.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY)>0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousControler(tp)
end
-- 除外区怪兽过滤条件：表侧表示且能加入手卡的怪兽
function c36733451.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动目标选择及合法性检测
function c36733451.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c36733451.filter(chkc) end
	-- 检查除外区是否存在合法的表侧怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c36733451.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只自己怪兽作为对象
	local g=Duel.SelectTarget(tp,c36733451.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将目标怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果②的操作：将作为对象的除外怪兽加入手卡
function c36733451.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
