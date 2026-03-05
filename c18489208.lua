--カースド・フィグ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，选择场上盖放的2张魔法·陷阱卡发动。只要这张卡在墓地存在，选择的卡不能发动。
function c18489208.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理被战斗破坏送入墓地时的发动条件
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
-- 效果发动的条件：这张卡在墓地且因战斗破坏而离开战场
function c18489208.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 选择场上盖放的2张魔法·陷阱卡作为效果的对象
function c18489208.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	if chk==0 then return true end
	-- 向玩家提示“请选择里侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择2张里侧表示的魔法·陷阱卡作为目标
	Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,2,2,nil)
end
-- 将被选择的卡设置为不能发动效果
function c18489208.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) then return end
	-- 获取当前连锁中选择的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
			-- 为被选择的卡注册一个不能发动效果的永续效果
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
-- 判断该卡是否被当前效果所关联，用于条件判断
function c18489208.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
