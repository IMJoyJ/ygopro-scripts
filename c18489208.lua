--カースド・フィグ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，选择场上盖放的2张魔法·陷阱卡发动。只要这张卡在墓地存在，选择的卡不能发动。
function c18489208.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，选择场上盖放的2张魔法·陷阱卡发动。只要这张卡在墓地存在，选择的卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18489208,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c18489208.con)
	e1:SetTarget(c18489208.tg)
	e1:SetOperation(c18489208.op)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：效果持有者（这张卡）在墓地且被战斗破坏。
function c18489208.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动时的目标选择：选择场上里侧表示的魔法·陷阱卡作为对象（取2张）。若检查目标合法性，要求目标在魔陷区且里侧表示；若发动确认，直接选择2张。
function c18489208.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家显示“请选择里侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 从双方魔陷区选择2张里侧表示的魔法·陷阱卡作为效果对象，并将其设为当前连锁的取对象目标。
	Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,2,2,nil)
end
-- 效果处理：若此卡仍在墓地，则取得发动时选择的对象卡；对每张仍里侧且与效果关联的卡，将此卡设为该卡的永续对象，并给该卡注册“不能发动效果”的永续效果；循环处理所有对象。
function c18489208.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) then return end
	-- 取得当前连锁中记录的对象卡组（即发动时选择的2张里侧魔法·陷阱卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			-- 只要这张卡在墓地存在，选择的卡不能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c18489208.rcon)
			tc:RegisterEffect(e1,true)
		end
		tc=g:GetNext()
	end
end
-- “不能发动”效果的适用条件：仅当作为效果持有者的无花果仍以对象卡为永续对象时，该禁发效果才适用。
function c18489208.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
