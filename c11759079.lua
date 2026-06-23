--双天脚の鴻鵠
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「双天脚之鸿鹄」以外的自己场上的表侧表示的「双天」怪兽在对方回合被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。
-- ●选自己场上1只「双天」怪兽破坏，从额外卡组把1只「双天」融合怪兽特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「双天」陷阱卡加入手卡。
function c11759079.initial_effect(c)
	-- ①：「双天脚之鸿鹄」以外的自己场上的表侧表示的「双天」怪兽在对方回合被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11759079,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11759079)
	e1:SetCondition(c11759079.spcon)
	e1:SetTarget(c11759079.sptg)
	e1:SetOperation(c11759079.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「双天」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11759079,1))  --"「双天」陷阱卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11759080)
	e2:SetTarget(c11759079.thtg)
	e2:SetOperation(c11759079.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断被破坏的怪兽是否满足条件：为「双天」怪兽、在对方回合被战斗或效果破坏、且不是自己本身。
function c11759079.spfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x14f) and c:GetPreviousCodeOnField()~=11759079
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断条件函数，用于判断是否可以发动效果①：场上存在满足spfilter条件的怪兽被破坏，且当前回合不是自己回合。
function c11759079.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果①的发动条件：存在满足spfilter条件的怪兽被破坏，且当前回合不是自己回合。
	return eg:IsExists(c11759079.spfilter,1,nil,tp) and Duel.GetTurnPlayer()~=tp
end
-- 设置效果①的目标函数，用于判断是否可以发动效果①。
function c11759079.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息：将自己特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于选择自己场上的「双天」怪兽作为破坏对象。
function c11759079.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14f)
		-- 检查是否满足效果①的后续处理条件：自己场上存在可破坏的「双天」怪兽，并且额外卡组存在可特殊召唤的「双天」融合怪兽。
		and Duel.IsExistingMatchingCard(c11759079.sffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数，用于选择额外卡组中满足条件的「双天」融合怪兽。
function c11759079.sffilter(c,e,tp,tc)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION)
		-- 检查是否满足特殊召唤融合怪兽的条件：融合怪兽可以被特殊召唤，且有足够空位。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 效果①的处理函数，用于执行效果①的处理。
function c11759079.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自己从手卡特殊召唤到场上。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查是否满足效果①的后续处理条件：自己场上存在可破坏的「双天」怪兽。
		and Duel.IsExistingMatchingCard(c11759079.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否选择破坏怪兽并特殊召唤融合怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(11759079,2)) then  --"是否要把怪兽破坏并特殊召唤融合怪兽？"
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择场上满足条件的「双天」怪兽进行破坏。
		local g=Duel.SelectMatchingCard(tp,c11759079.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		-- 显示被选中的怪兽作为破坏对象的动画效果。
		Duel.HintSelection(g)
		-- 将选中的怪兽破坏。
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 提示玩家选择要特殊召唤的融合怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			-- 从额外卡组选择满足条件的「双天」融合怪兽。
			local sg=Duel.SelectMatchingCard(tp,c11759079.sffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
			if sg:GetCount()>0 then
				-- 将选中的融合怪兽特殊召唤到场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 过滤函数，用于选择卡组中满足条件的「双天」陷阱卡。
function c11759079.thfilter(c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果②的目标函数，用于判断是否可以发动效果②。
function c11759079.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在满足thfilter条件的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11759079.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果②的处理信息：将一张陷阱卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数，用于执行效果②的处理。
function c11759079.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组选择满足条件的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c11759079.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被选中的陷阱卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
