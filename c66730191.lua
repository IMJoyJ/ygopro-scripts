--燦幻開門
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡在战斗阶段发动的场合，以下效果各能适用。这张卡在战斗阶段以外发动的场合，从以下效果选1个适用。
-- ●从卡组把1只4星以下的龙族·炎属性怪兽加入手卡。
-- ●从手卡把1只龙族·炎属性怪兽特殊召唤。
function c66730191.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡在战斗阶段发动的场合，以下效果各能适用。这张卡在战斗阶段以外发动的场合，从以下效果选1个适用。●从卡组把1只4星以下的龙族·炎属性怪兽加入手卡。●从手卡把1只龙族·炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66730191+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c66730191.target)
	e1:SetOperation(c66730191.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中4星以下的龙族·炎属性且能加入手卡的怪兽
function c66730191.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 过滤手卡中可以特殊召唤的龙族·炎属性怪兽
function c66730191.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测与操作信息注册
function c66730191.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的怪兽
	local b1=Duel.IsExistingMatchingCard(c66730191.filter,tp,LOCATION_DECK,0,1,nil)
	-- 检查自身场上是否有空位且手卡中是否存在满足特召条件的怪兽
	local b2=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(c66730191.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 注册将卡组的卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 注册从手卡特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c66730191.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段
	local ph=Duel.GetCurrentPhase()
	local op=0
	-- 效果处理时，再次检查卡组中是否存在满足检索条件的怪兽
	local b1=Duel.IsExistingMatchingCard(c66730191.filter,tp,LOCATION_DECK,0,1,nil)
	-- 效果处理时，再次检查自身场上是否有空位且手卡中是否存在满足特召条件的怪兽
	local b2=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(c66730191.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	if b1 then
		-- 若无法进行特殊召唤，或玩家选择执行检索效果，则进行检索处理
		if not b2 or Duel.SelectYesNo(tp,aux.Stringid(66730191,1)) then  --"是否从卡组加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1张满足检索条件的卡
			local g=Duel.SelectMatchingCard(tp,c66730191.filter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡因效果加入手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 让对方玩家确认加入手卡的卡
				Duel.ConfirmCards(1-tp,g)
			end
			op=1
		end
	end
	-- 重新检查是否满足特殊召唤的条件（防止检索效果处理后状态改变）
	b2=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(c66730191.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 若满足特召条件，且（未执行检索效果，或在战斗阶段中且玩家选择执行特召效果），则进行特召处理
	if b2 and (op==0 or ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and Duel.SelectYesNo(tp,aux.Stringid(66730191,2))) then  --"是否从手卡特殊召唤？"
		if op~=0 then
			-- 中断当前效果处理，使后续的特殊召唤与前面的检索不视为同时处理
			Duel.BreakEffect()
		end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1张满足特召条件的卡
		local g=Duel.SelectMatchingCard(tp,c66730191.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自身场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
