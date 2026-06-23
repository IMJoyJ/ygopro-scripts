--星因士 ベテルギウス
-- 效果：
-- 「星因士 参宿四」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以「星因士 参宿四」以外的自己墓地1张「星骑士」卡为对象才能发动。这张卡送去墓地，作为对象的卡加入手卡。
function c26057276.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以「星因士 参宿四」以外的自己墓地1张「星骑士」卡为对象才能发动。这张卡送去墓地，作为对象的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26057276,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,26057276)
	e1:SetTarget(c26057276.target)
	e1:SetOperation(c26057276.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c26057276.star_knight_summon_effect=e1
end
-- 过滤满足条件的墓地「星骑士」卡（排除自身）
function c26057276.filter(c)
	return c:IsSetCard(0x9c) and not c:IsCode(26057276) and c:IsAbleToHand()
end
-- 设置效果目标为满足条件的墓地「星骑士」卡
function c26057276.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26057276.filter(chkc) end
	-- 判断是否满足发动条件：存在满足条件的墓地「星骑士」卡
	if chk==0 then return Duel.IsExistingTarget(c26057276.filter,tp,LOCATION_GRAVE,0,1,exc) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「星骑士」卡作为效果对象
	local g=Duel.SelectTarget(tp,c26057276.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将对象卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将自身送去墓地并把对象卡加入手牌
function c26057276.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身在场上且成功送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 获取效果对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
