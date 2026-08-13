--星因士 ベテルギウス
-- 效果：
-- 「星因士 参宿四」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以「星因士 参宿四」以外的自己墓地1张「星骑士」卡为对象才能发动。这张卡送去墓地，作为对象的卡加入手卡。
function c26057276.initial_effect(c)
	-- 「星因士 参宿四」的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合，以「星因士 参宿四」以外的自己墓地1张「星骑士」卡为对象才能发动。这张卡送去墓地，作为对象的卡加入手卡。
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
-- 筛选条件：对象必须是「星骑士」卡、不能是「星因士 参宿四」自身、且能加入手卡。
function c26057276.filter(c)
	return c:IsSetCard(0x9c) and not c:IsCode(26057276) and c:IsAbleToHand()
end
-- 发动时的目标处理：先核对对象资格（自己墓地的「星骑士」卡且非自身），再让玩家选择1张符合条件的卡作为对象，并设定效果处理的类别为回手牌。
function c26057276.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,exc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26057276.filter(chkc) end
	-- 效果发动合法性检查：确认自己墓地是否存在至少1张符合条件的「星骑士」卡可选作对象。
	if chk==0 then return Duel.IsExistingTarget(c26057276.filter,tp,LOCATION_GRAVE,0,1,exc) end
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的卡作为效果对象，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c26057276.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：宣告本效果将把对象卡加入手牌（CATEGORY_TOHAND），预定处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：把此卡送去墓地（成功且位于墓地时），再将其对象卡加入持有者手卡。
function c26057276.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定条件：此卡仍与效果关联（未被无效/离场重置），且被效果成功送去墓地并处于墓地，才继续执行后续回手牌处理。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 取得本效果的对象（之前选择的那张墓地「星骑士」卡）。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡加入其持有者的手卡（REASON_EFFECT）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
