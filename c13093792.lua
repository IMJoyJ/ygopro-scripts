--D-HERO ダイヤモンドガイ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡翻开，那是通常魔法卡的场合，那张卡送去墓地。不是的场合，那张卡回到卡组最下面。这个效果把通常魔法卡送去墓地的场合，下次的自己回合的主要阶段可以把墓地的那张通常魔法卡的发动时的效果发动。
function c13093792.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13093792,0))  --"发动魔法卡效果"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c13093792.target)
	e1:SetOperation(c13093792.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c13093792.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动此效果（卡组不为空）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置连锁操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果作用
function c13093792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组是否为空，为空则返回
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 翻开自己卡组最上面的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上面的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:GetType()==TYPE_SPELL then
		-- 禁用洗卡检测
		Duel.DisableShuffleCheck()
		-- 将该卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		local ae=tc:GetActivateEffect()
		if tc:IsLocation(LOCATION_GRAVE) and ae then
			-- ①：这个效果把通常魔法卡送去墓地的场合，下次的自己回合的主要阶段可以把墓地的那张通常魔法卡的发动时的效果发动。
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(ae:GetDescription())
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
			e1:SetCondition(c13093792.spellcon)
			e1:SetTarget(c13093792.spelltg)
			e1:SetOperation(c13093792.spellop)
			tc:RegisterEffect(e1)
		end
	else
		-- 将该卡移回卡组最下面
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 效果作用
function c13093792.spellcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为下个回合的主要阶段
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 效果作用
function c13093792.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ae=e:GetHandler():GetActivateEffect()
	local ftg=ae:GetTarget()
	if chk==0 then
		e:SetCostCheck(false)
		return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else e:SetProperty(0) end
	if ftg then
		e:SetCostCheck(false)
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
-- 效果作用
function c13093792.spellop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end
