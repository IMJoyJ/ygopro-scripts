--戦華の詭－賈文
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，选场上2只表侧表示怪兽，那些攻击力直到回合结束时变成一半。
-- ②：对方场上的卡被战斗·效果破坏的场合，以「战华之诡-贾文」以外的自己墓地1张「战华」卡为对象才能发动。那张卡加入手卡。
function c6438003.initial_effect(c)
	-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，选场上2只表侧表示怪兽，那些攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6438003,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,6438003)
	e1:SetTarget(c6438003.atktg)
	e1:SetOperation(c6438003.atkop)
	c:RegisterEffect(e1)
	-- ②：对方场上的卡被战斗·效果破坏的场合，以「战华之诡-贾文」以外的自己墓地1张「战华」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6438003,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,6438004)
	e2:SetCondition(c6438003.thcon)
	e2:SetTarget(c6438003.thtg)
	e2:SetOperation(c6438003.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、且能送去墓地的永续魔法或永续陷阱卡，并且此时场上存在至少2只其他的表侧表示怪兽
function c6438003.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGrave()
		-- 检查场上是否存在至少2只表侧表示的怪兽（排除作为对象的永续魔陷本身）
		and Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,2,c)
end
-- 效果①的靶向与发动准备：选择自己场上1张永续魔法·永续陷阱卡作为对象，并设置送去墓地的操作信息
function c6438003.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c6438003.tgfilter(chkc) end
	-- 发动检查：自己场上是否存在可以送去墓地的表侧表示永续魔法·永续陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c6438003.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张表侧表示的永续魔法·永续陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c6438003.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果①的执行：将作为对象的卡送去墓地，若成功，则选场上2只表侧表示怪兽，使其攻击力直到回合结束时变成一半
function c6438003.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍适用此效果，且成功将其送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上2只表侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
		if g:GetCount()==2 then
			-- 为选中的怪兽显示被选择的动画效果
			Duel.HintSelection(g)
			local tc1=g:GetFirst()
			local tc2=g:GetNext()
			-- 那些攻击力直到回合结束时变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(math.ceil(tc1:GetAttack()/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc1:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetValue(math.ceil(tc2:GetAttack()/2))
			tc2:RegisterEffect(e2)
		end
	end
end
-- 过滤条件：因战斗或效果被破坏的对方场上的卡
function c6438003.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(1-tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的发动条件：对方场上的卡被战斗·效果破坏的场合
function c6438003.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c6438003.cfilter,1,nil,tp)
end
-- 过滤条件：自己墓地中「战华之诡-贾文」以外的「战华」卡，且能加入手卡
function c6438003.thfilter(c)
	return c:IsSetCard(0x137) and not c:IsCode(6438003) and c:IsAbleToHand()
end
-- 效果②的靶向与发动准备：选择自己墓地1张「战华」卡作为对象，并设置加入手卡的操作信息
function c6438003.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6438003.thfilter(chkc) end
	-- 发动检查：自己墓地是否存在满足条件的「战华」卡
	if chk==0 then return Duel.IsExistingTarget(c6438003.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「战华」卡作为效果对象
	local g=Duel.SelectTarget(tp,c6438003.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的执行：将作为对象的墓地中的卡加入手卡
function c6438003.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
