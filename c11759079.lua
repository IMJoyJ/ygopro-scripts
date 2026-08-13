--双天脚の鴻鵠
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「双天脚之鸿鹄」以外的自己场上的表侧表示的「双天」怪兽在对方回合被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。
-- ●选自己场上1只「双天」怪兽破坏，从额外卡组把1只「双天」融合怪兽特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「双天」陷阱卡加入手卡。
function c11759079.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：「双天脚之鸿鹄」以外的自己场上的表侧表示的「双天」怪兽在对方回合被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，以下效果可以适用。●选自己场上1只「双天」怪兽破坏，从额外卡组把1只「双天」融合怪兽特殊召唤。
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
-- 筛选被破坏的怪兽是否满足：由战斗或效果破坏、破坏前表侧表示存在于我方怪兽区、属于「双天」系列且卡名不是「双天脚之鸿鹄」、控制权为我方。
function c11759079.spfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0x14f) and c:GetPreviousCodeOnField()~=11759079
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 判断①效果能否发动：本次被破坏的怪兽中存在满足spfilter的怪兽，且当前是对方回合。
function c11759079.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被破坏的怪兽组中是否存在符合条件的「双天」怪兽，并确认当前为对方回合。
	return eg:IsExists(c11759079.spfilter,1,nil,tp) and Duel.GetTurnPlayer()~=tp
end
-- ①效果发动时进行合法性检查：自己场上主要怪兽区有空位，且手卡中的这张卡能够被特殊召唤。
function c11759079.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作信息：将特殊召唤手卡中这张卡的操作类别、对象和数量告知系统，供时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 选择要破坏的「双天」怪兽的过滤条件：该怪兽表侧表示且属于「双天」系列，并且额外卡组存在可特殊召唤的「双天」融合怪兽。
function c11759079.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14f)
		-- 检查额外卡组是否存在至少1只可特殊召唤的「双天」融合怪兽，以保证后续特殊召唤能成立。
		and Duel.IsExistingMatchingCard(c11759079.sffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 选择额外卡组「双天」融合怪兽的过滤条件：该融合怪兽属于「双天」系列、能够特殊召唤，且破坏拟选怪兽后自己场上仍有空位。
function c11759079.sffilter(c,e,tp,tc)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION)
		-- 确认该融合怪兽可以被特殊召唤，且破坏候选怪兽后场上仍有可供其出场的空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- ①效果处理：先将手卡中的这张卡特殊召唤；成功后若场上有可破坏的「双天」怪兽且玩家选择适用，则破坏1只「双天」怪兽，并从额外卡组特殊召唤1只「双天」融合怪兽。
function c11759079.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡从手卡特殊召唤，若特殊召唤成功（返回值不为0）才继续后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在可作为破坏对象的「双天」怪兽，以决定是否提供后续选项。
		and Duel.IsExistingMatchingCard(c11759079.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否要适用“破坏自己场上1只「双天」怪兽，从额外卡组特殊召唤1只「双天」融合怪兽”的后续效果。
		and Duel.SelectYesNo(tp,aux.Stringid(11759079,2)) then  --"是否要把怪兽破坏并特殊召唤融合怪兽？"
		-- 中断当前效果处理，使后续破坏与特殊召唤不再与之前的特殊召唤同时进行，以免错过时点。
		Duel.BreakEffect()
		-- 发出选择要破坏的「双天」怪兽的操作提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从自己场上选择1只满足desfilter条件的「双天」怪兽作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,c11759079.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		-- 展示所选卡片被选为对象的动画，并将其记录为当前效果的对象。
		Duel.HintSelection(g)
		-- 用效果破坏所选「双天」怪兽；若实际破坏成功，则继续处理融合特殊召唤。
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 发出选择要特殊召唤的「双天」融合怪兽的操作提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足sffilter条件的「双天」融合怪兽。
			local sg=Duel.SelectMatchingCard(tp,c11759079.sffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
			if sg:GetCount()>0 then
				-- 将选中的「双天」融合怪兽特殊召唤到自己场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 筛选卡组中满足以下条件的卡：属于「双天」系列、是陷阱卡、且可以加入手卡。
function c11759079.thfilter(c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动条件与目标设定：卡组中存在可检索的「双天」陷阱卡，并登记从卡组加入手卡的操作信息。
function c11759079.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查卡组中是否存在至少1张符合条件的「双天」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c11759079.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：从卡组将1张卡加入手卡（具体卡在效果处理时选定，故目标暂为空）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「双天」陷阱卡加入手卡，并向对方玩家展示确认。
function c11759079.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择要加入手卡的「双天」陷阱卡的操作提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter条件的「双天」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c11759079.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「双天」陷阱卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
