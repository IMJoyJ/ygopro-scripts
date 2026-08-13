--捕食活動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「捕食植物」怪兽特殊召唤。那之后，从卡组把「捕食活动」以外的1张「捕食」卡加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c31643613.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把1只「捕食植物」怪兽特殊召唤。那之后，从卡组把「捕食活动」以外的1张「捕食」卡加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31643613+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c31643613.sptg)
	e1:SetOperation(c31643613.spop)
	c:RegisterEffect(e1)
end
-- 筛选从手卡特殊召唤的对象：必须是「捕食植物」怪兽，且可以被当前效果特殊召唤。
function c31643613.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选检索的对象：必须是「捕食」卡，且不是「捕食活动」本身，并且可以被加入手卡。
function c31643613.thfilter(c)
	return c:IsSetCard(0xf3) and not c:IsCode(31643613) and c:IsAbleToHand()
end
-- 效果发动前检查是否满足条件：自己主要怪兽区有空位，手牌中存在可特殊召唤的「捕食植物」怪兽，且卡组中存在可检索的「捕食」卡。
function c31643613.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定时，第一项条件：自己场上存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 第二项条件：手牌中存在至少1只可被特殊召唤的「捕食植物」怪兽。
		and Duel.IsExistingMatchingCard(c31643613.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 第三项条件：卡组中存在至少1张可加入手卡的「捕食」卡。
		and Duel.IsExistingMatchingCard(c31643613.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：效果包含特殊召唤，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：效果包含将卡加入手卡，预计从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从手卡选1只「捕食植物」怪兽特殊召唤；成功后中断效果处理，再从卡组选1张「捕食」卡加入手卡并给对方确认；最后给己方附加直到回合结束不能从额外卡组特殊召唤非融合怪兽的限制。
function c31643613.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向操作玩家发出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的「捕食植物」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c31643613.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若选择的怪兽存在且特殊召唤成功（返回数量不为0），则继续执行后续检索处理。
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使特殊召唤成功与后续检索作为不同时点处理，防止错过时点。
		Duel.BreakEffect()
		-- 向操作玩家发出选择提示：请选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足条件的「捕食」卡作为加入手卡的对象。
		local g2=Duel.SelectMatchingCard(tp,c31643613.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g2>0 then
			-- 将选中的「捕食」卡加入其持有者的手卡（处理原因为效果）。
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 将检索到并加入手卡的那张卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31643613.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制的永续效果注册给当前玩家，使其在回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定：若怪兽来自额外卡组且不是融合怪兽，则不能特殊召唤。
function c31643613.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
