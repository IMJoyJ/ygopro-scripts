--廻る罪宝
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组选1只5星以上的幻想魔族怪兽加入手卡或特殊召唤。这个回合的主要阶段内，自己不能把这个效果特殊召唤的怪兽的效果发动。
-- ②：把墓地的这张卡除外，以自己场上1张里侧表示卡为对象才能发动。那张卡回到手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。
local s,id,o=GetID()
-- 注册这张卡的①和②两个效果：①为魔法卡发动效果，②为墓地中发动、以除外自身为cost的即时效果；分别设置描述、分类、类型、发动时机、次数限制、目标与操作函数。
function s.initial_effect(c)
	-- ①：从卡组选1只5星以上的幻想魔族怪兽加入手卡或特殊召唤。这个回合的主要阶段内，自己不能把这个效果特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1张里侧表示卡为对象才能发动。那张卡回到手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 设置效果②的发动代价为：将墓地的这张卡除外（aux.bfgcost实现移除自身为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 定义效果①检索卡组的筛选函数：选择5星以上、幻想魔族，且满足加入手卡或特殊召唤条件的怪兽。
function s.sfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5) and (c:IsAbleToHand()
		-- 或满足特殊召唤条件：自己场上有可用怪兽区域，且该卡能被效果特殊召唤（不无视召唤条件与苏生限制）。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果①的发动条件判定：发动时检查卡组中是否存在1张以上符合s.sfilter条件的怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若chk为0，则确认卡组中有至少1张满足条件的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果①处理：从卡组选择1张符合条件的怪兽，若可加入手卡则加入手卡，若可特殊召唤则特殊召唤；若选择特殊召唤，则给该怪兽附加本回合主要阶段内不能发动效果的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要操作的卡”的提示信息，用于后续选择卡组中的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组筛选并选择1张符合s.sfilter的怪兽卡，作为本次效果处理的选定卡。
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local th=tc:IsAbleToHand()
		-- 判断选定怪兽是否可以被特殊召唤：自己场上存在空余的怪兽区域，且该怪兽在此效果下能满足特殊召唤条件。
		local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		-- 若该怪兽既能加入手卡又能特殊召唤，则让玩家选择处理方式（加入手卡或特殊召唤）。
		if th and sp then op=Duel.SelectOption(tp,1190,1152)
		elseif th then op=0
		else op=1 end
		if op==0 then
			-- 将选定的怪兽加入其持有者的手卡（nil表示返回持有者手卡），处理原因为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的这张卡片展示给对手（1-tp）确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 以表侧表示将选定的怪兽特殊召唤到自己场上；SpecialSummonStep用于在特召同时给怪兽附加限制效果，成功则继续。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 这个回合的主要阶段内，自己不能把这个效果特殊召唤的怪兽的效果发动。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetCondition(s.condition)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			-- 完成所有SpecialSummonStep特殊召唤处理，确认特殊召唤成功。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 定义限制效果的生效条件：当前阶段为主要阶段1或主要阶段2。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，以满足“这个回合的主要阶段内”的时限。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义效果②取对象时的卡片筛选条件：自己场上的里侧表示卡且能够加入手卡。
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果②的发动目标选择：选择自己场上1张里侧表示卡作为对象，并设置加入手牌的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.thfilter(chkc) end
	-- 效果发动合法性检查：确认自己场上有至少1张满足条件的里侧表示卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己场上1张里侧表示卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，声明本效果包含将1张卡加入手牌，便于其他卡进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理：先将对象卡送回持有者手卡；若成功且该卡在手卡中，则可选择1张手卡中的魔法·陷阱卡盖放到自己场上。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与此效果关联（未被移离原区域等），然后将其送入持有者手卡；若实际送回成功且该卡现在位于手卡，则继续后续盖放处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取自己手卡中所有可以盖放（Set）的魔法·陷阱卡，作为可选盖放的候选。
		local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 如果手卡中有可盖放的魔陷，则询问玩家是否要盖放一张，玩家选择“是”则进入盖放处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否盖放？"
			-- 洗切手卡，重置洗牌检测状态（因为随后要从手卡选择并取出卡片）。
			Duel.ShuffleHand(tp)
			-- 中断当前效果链，使后续的盖放处理视为不同时处理，避免错误时点。
			Duel.BreakEffect()
			-- 显示“请选择要盖放的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的1张手卡中的魔法·陷阱卡里侧盖放到自己的魔法与陷阱区域（false表示只盖放不发动）。
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
