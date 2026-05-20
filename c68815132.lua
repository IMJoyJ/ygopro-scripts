--ハーピィ・ダンサー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：以自己场上1只风属性怪兽为对象才能发动。那只怪兽回到持有者手卡。那之后，可以把1只风属性怪兽召唤。
function c68815132.initial_effect(c)
	-- ②：以自己场上1只风属性怪兽为对象才能发动。那只怪兽回到持有者手卡。那之后，可以把1只风属性怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68815132,0))  --"返回手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,68815132)
	e1:SetTarget(c68815132.target)
	e1:SetOperation(c68815132.operation)
	c:RegisterEffect(e1)
	-- 注册一个在场上和墓地生效的效果，使这张卡的卡名当作「鹰身女郎」使用。
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 过滤条件：场上表侧表示、风属性且能回到手牌的怪兽。
function c68815132.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择。
function c68815132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68815132.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足条件的可回到手牌的风属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c68815132.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只风属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c68815132.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果包含将选中的卡送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：手牌或场上可以进行通常召唤的风属性怪兽。
function c68815132.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSummonable(true,nil)
end
-- 效果②的效果处理（回手牌及后续的召唤处理）。
function c68815132.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果，则将其送回持有者手牌，并确认其已成功回到手牌。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 检查手牌或场上是否存在可以召唤的风属性怪兽。
		if Duel.IsExistingMatchingCard(c68815132.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否选择进行风属性怪兽的召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(68815132,1)) then  --"是否要选择1只风属性怪兽召唤？"
			-- 中断当前效果处理，使后续的召唤处理与回手牌不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 选择1只手牌或场上满足召唤条件的风属性怪兽。
			local g=Duel.SelectMatchingCard(tp,c68815132.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			-- 将选择的怪兽进行通常召唤（忽略每回合的通常召唤次数限制）。
			Duel.Summon(tp,g:GetFirst(),true,nil)
		end
	end
end
