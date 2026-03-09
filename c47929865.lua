--マジドッグ
-- 效果：
-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以选择自己墓地存在的1张场地魔法卡加入手卡。
function c47929865.initial_effect(c)
	-- 效果原文内容：这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以选择自己墓地存在的1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47929865,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c47929865.thcon)
	e1:SetTarget(c47929865.thtg)
	e1:SetOperation(c47929865.thop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断此卡是否因同调召唤而作为素材进入墓地且其作为素材的怪兽为魔法师族。
function c47929865.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_SPELLCASTER)
end
-- 规则层面操作：定义可选卡片类型为场地魔法卡且能加入手牌。
function c47929865.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果目标选择，允许玩家从自己墓地中选择一张符合条件的场地魔法卡。
function c47929865.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c47929865.filter(chkc) end
	-- 规则层面操作：检查是否有满足条件的卡片存在以确保可以发动此效果。
	if chk==0 then return Duel.IsExistingTarget(c47929865.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：向玩家发送提示信息“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择目标卡片，即从自己墓地中选择一张场地魔法卡。
	local g=Duel.SelectTarget(tp,c47929865.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面操作：设置连锁操作信息，表明此效果将把一张卡送入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果原文内容：这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以选择自己墓地存在的1张场地魔法卡加入手卡。
function c47929865.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中选定的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标卡片以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认该张被送入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
