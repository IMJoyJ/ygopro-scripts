--エレクトロ軍曹
-- 效果：
-- ①：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的盖放的卡不能发动。
function c43359262.initial_effect(c)
	-- ①：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43359262,0))  --"发动限制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c43359262.target)
	e1:SetOperation(c43359262.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的卡：对方魔陷区里侧表示、不在场地魔法格（格子5）、且尚未被这张卡选为永续对象的卡。
function c43359262.filter(c,rc)
	return c:IsFacedown() and c:GetSequence()~=5 and not rc:IsHasCardTarget(c)
end
-- 发动时的目标处理：先检查对方魔陷区是否存在1张符合条件的里侧盖卡；若存在则提示玩家选择其中1张作为对象，并将该卡设为效果的对象。
function c43359262.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c43359262.filter(chkc,e:GetHandler()) end
	-- 效果发动的合法性检查：若对方魔陷区存在至少1张符合条件的里侧盖卡，则允许发动。
	if chk==0 then return Duel.IsExistingTarget(c43359262.filter,tp,0,LOCATION_SZONE,1,nil,e:GetHandler()) end
	-- 向发动玩家显示“请选择里侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让发动玩家从对方魔陷区选择1张符合条件的里侧表示盖卡，并将其登记为本效果的对象。
	Duel.SelectTarget(tp,c43359262.filter,tp,0,LOCATION_SZONE,1,1,nil,e:GetHandler())
end
-- 效果处理：若电力军曹仍与效果关联且目标卡仍为里侧表示并与效果关联，则将该目标卡设为电力军曹的永续对象，并注册一个永续效果使该目标卡不能发动。
function c43359262.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的效果对象卡，即发动时选择的那张对方里侧魔陷。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- ●只要这张卡在怪兽区域存在，作为对象的盖放的卡不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		e1:SetTarget(c43359262.distg)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 作为“不能发动”效果的筛选条件：若某张卡为里侧表示且被电力军曹永续指向，则该卡不能发动效果。
function c43359262.distg(e,c)
	return c:IsFacedown() and e:GetHandler():IsHasCardTarget(c)
end
