--泥岩の霊長－マンドストロング
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地选「泥岩灵长-强壮泥岩山魈」以外的1只怪兽加入手卡。
function c37021315.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37021315.regcon)
	e2:SetOperation(c37021315.regop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤。那之后，可以从自己墓地选「泥岩灵长-强壮泥岩山魈」以外的1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37021315,0))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,37021315)
	e3:SetCondition(c37021315.spcon)
	e3:SetTarget(c37021315.sptg)
	e3:SetOperation(c37021315.spop)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果②的发动条件：卡片从场上背面表示被破坏送去墓地，且破坏者为对方。
function c37021315.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and rp==1-tp
end
-- 为该卡注册一个标记，用于记录其是否已发动过效果②。
function c37021315.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(37021315,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否已发动过效果②：检查是否有标记。
function c37021315.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(37021315)>0
end
-- 设置效果②的发动条件：判断是否满足特殊召唤的条件。
function c37021315.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将该卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义过滤函数：选择墓地中的怪兽，且不能是此卡本身。
function c37021315.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(37021315)
end
-- 执行效果②的处理：特殊召唤此卡，并询问是否从墓地选怪兽加入手牌。
function c37021315.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍存在于场上，且成功特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断墓地中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c37021315.cfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否发动后续效果：从墓地选怪兽加入手牌。
		and Duel.SelectYesNo(tp,aux.Stringid(37021315,1)) then  --"是否从墓地把怪兽加入手卡？"
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的1张墓地怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37021315.cfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选怪兽的卡面信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
