--マジドッグ
-- 效果：
-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以选择自己墓地存在的1张场地魔法卡加入手卡。
function c47929865.initial_effect(c)
	-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以选择自己墓地存在的1张场地魔法卡加入手卡。
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
-- 效果发动条件：此卡因作为同调素材被送去墓地且位于墓地，同调召唤的怪兽（导致此卡位置变化的卡）为魔法师族。
function c47929865.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_SPELLCASTER)
end
-- 筛选条件：自己墓地的场地魔法卡，且这张卡能加入手卡（不受“不能加入手卡”等效果限制）。
function c47929865.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 发动时选择对象的处理：先验证chain target合法性；在发动时检查是否存在可选择的墓场地魔法卡；然后提示玩家选择1张自己墓地的场地魔法卡作为对象，并设置回手牌的操作信息。
function c47929865.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c47929865.filter(chkc) end
	-- 在效果发动时检查自己墓地是否存在至少1张符合条件的场地魔法卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c47929865.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地的符合条件的场地魔法卡中选择1张作为效果对象，并设为当前连锁的取对象。
	local g=Duel.SelectTarget(tp,c47929865.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：类别为回手牌（CATEGORY_TOHAND），目标为已选择的卡，数量为1，方便其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象卡，若它仍与此效果有关联（未被无效/未离场），则将其加入持有者手牌，并让对方确认该卡。
function c47929865.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中选定的对象卡（墓地那张场地魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该卡送去其持有者的手卡（加入手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认这张加入手卡的卡（公开信息）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
