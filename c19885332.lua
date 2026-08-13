--白の水鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的鱼族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把原本卡名和这个效果特殊召唤的怪兽相同的1只怪兽从卡组加入手卡。
function c19885332.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只4星以下的鱼族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把原本卡名和这个效果特殊召唤的怪兽相同的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19885332+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19885332.target)
	e1:SetOperation(c19885332.activate)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：等级4以下、鱼族，且可以被效果特殊召唤。
function c19885332.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动阶段：先确认连锁对象是否为己方墓地满足过滤条件的怪兽；再检查己方主要怪兽区有空位且墓地存在符合条件的对象。
function c19885332.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19885332.filter(chkc,e,tp) end
	-- 检查己方主要怪兽区是否有空位，确保特殊召唤有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地是否存在1只以上满足过滤条件的鱼族怪兽，且能成为效果对象。
		and Duel.IsExistingTarget(c19885332.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择1只满足条件的鱼族怪兽，并设置为该连锁的效果对象。
	local g=Duel.SelectTarget(tp,c19885332.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义检索过滤条件：卡组中原本卡名与特殊召唤的怪兽相同的卡，并且可以加入手卡。
function c19885332.thfilter(c,code)
	return c:IsOriginalCodeRule(code) and c:IsAbleToHand()
end
-- 效果处理：将对象怪兽特殊召唤；若成功且玩家选择进行检索，则从卡组将1只同名卡加入手卡，并向对方展示该卡。
function c19885332.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本次效果关联，且成功特殊召唤后，才继续执行后续检索。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从卡组筛选出原本卡名与特殊召唤怪兽相同的卡。
		local g=Duel.GetMatchingGroup(c19885332.thfilter,tp,LOCATION_DECK,0,nil,tc:GetOriginalCodeRule())
		-- 当存在可检索的同名卡且玩家确认发动追加效果时，进入处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19885332,0)) then  --"是否从卡组把同名卡加入手卡？"
			-- 中断当前效果链，使特殊召唤与后续检索视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 弹出选择提示，让玩家选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡以效果原因加入手卡。
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
