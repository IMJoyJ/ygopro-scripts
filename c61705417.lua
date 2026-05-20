--墓荒らし
-- 效果：
-- 选择对方墓地的1张魔法卡，直到回合结束时可以作为自己的手卡使用。使用那张魔法卡的场合，受到2000分伤害。
function c61705417.initial_effect(c)
	-- 选择对方墓地的1张魔法卡，直到回合结束时可以作为自己的手卡使用。使用那张魔法卡的场合，受到2000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61705417.target)
	e1:SetOperation(c61705417.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方墓地中可以加入手牌的魔法卡
function c61705417.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果的发动准备与对象选择
function c61705417.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c61705417.filter(chkc) end
	-- 检查对方墓地是否存在可以加入手牌的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c61705417.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择对方墓地的1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c61705417.filter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置将该卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标卡加入手牌，并注册后续的归还与伤害检测效果
function c61705417.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入发动效果玩家的手牌
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
		tc:RegisterFlagEffect(61705417,RESET_EVENT+0x5c0000+RESET_PHASE+PHASE_END,0,1)
		-- 直到回合结束时可以作为自己的手卡使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c61705417.tgcon)
		e1:SetOperation(c61705417.tgop)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+0x5c0000+RESET_PHASE+PHASE_END)
		-- 注册回合结束时将未使用的该卡送去墓地的效果
		Duel.RegisterEffect(e1,tp)
		-- 使用那张魔法卡的场合
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAINING)
		e3:SetCondition(c61705417.actcon)
		e3:SetOperation(c61705417.actop)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册用于检测该魔法卡发动的效果
		Duel.RegisterEffect(e3,tp)
		-- 受到2000分伤害。
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVED)
		e4:SetCondition(c61705417.damcon)
		e4:SetOperation(c61705417.damop)
		e4:SetLabelObject(tc)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在该魔法卡发动处理完毕后给予玩家伤害的效果
		Duel.RegisterEffect(e4,tp)
	end
end
-- 检查回合结束时该卡是否仍在非持有者（即盗墓者发动者）的手牌中
function c61705417.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetControler()~=tc:GetOwner() and tc:GetFlagEffect(61705417)~=0
end
-- 回合结束时将未使用的该卡送去墓地
function c61705417.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该卡送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- 检查玩家是否发动了被盗墓者加入手牌的那张魔法卡
function c61705417.actcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler()==e:GetLabelObject() and re:GetHandler():GetFlagEffect(61705417)~=0
end
-- 在该魔法卡发动时，为其注册标记以准备进行伤害处理，并重置此检测效果
function c61705417.actop(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(61705418,RESET_CHAIN,0,1)
	e:Reset()
end
-- 检查被使用的魔法卡是否已处理完毕且带有伤害标记
function c61705417.damcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler()==e:GetLabelObject() and re:GetHandler():GetFlagEffect(61705418)~=0
end
-- 重置标记并给予玩家2000点伤害，随后重置此伤害效果
function c61705417.damop(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():ResetFlagEffect(61705418)
	-- 给予发动效果的玩家2000点伤害
	Duel.Damage(tp,2000,REASON_EFFECT)
	e:Reset()
end
