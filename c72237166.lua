--カイザー・サクリファイス
-- 效果：
-- 这张卡为祭品的祭品召唤成功时，这张卡回到手卡。
function c72237166.initial_effect(c)
	-- 这张卡为祭品的祭品召唤成功时，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72237166,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCondition(c72237166.retcon)
	e1:SetTarget(c72237166.rettg)
	e1:SetOperation(c72237166.retop)
	c:RegisterEffect(e1)
end
-- 检查这张卡被解放的原因是否是为了进行祭品召唤（上级召唤）
function c72237166.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 效果发动的目标处理，作为必发效果直接返回true，并设置将自身加入手卡的操作信息
function c72237166.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将自身（1张卡）加入持有者的手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理的执行函数，若自身仍与效果有关联，则将自身加入手卡并给对方确认
function c72237166.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将自身送回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
