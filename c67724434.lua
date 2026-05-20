--ダブル・ワイルド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只5星以下的怪兽为对象才能发动。原本种族和那只怪兽相同的1只10星怪兽从卡组加入手卡。那之后，以下效果可以适用。这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
-- ●选自己1张手卡丢弃，种族和这个效果加入的怪兽相同的怪兽从手卡守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义该卡的发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只5星以下的怪兽为对象才能发动。原本种族和那只怪兽相同的1只10星怪兽从卡组加入手卡。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的5星以下怪兽，且卡组中存在与其原本种族相同的10星怪兽。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsLevelBelow(5)
		-- 检查卡组中是否存在与该怪兽原本种族相同的可检索10星怪兽。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace())
end
-- 过滤条件：与指定种族相同、等级为10且可以加入手牌的怪兽。
function s.thfilter(c,race)
	return c:IsRace(race) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与处理，检查合法对象并进行取对象操作，设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	-- 检查自己场上是否存在满足条件的5星以下怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只5星以下的怪兽作为对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息，表示该效果包含从卡组将卡加入手牌的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：可以丢弃的手牌，且手牌中存在可以特殊召唤的与指定种族相同的怪兽。
function s.hdfilter(c,e,tp,race)
	-- 检查该手牌是否可以丢弃，且手牌中是否存在其他可特殊召唤的相同种族怪兽。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp,race)
end
-- 过滤条件：可以守备表示特殊召唤的与指定种族相同的怪兽。
function s.spfilter(c,e,tp,race)
	-- 检查怪兽区域是否有空位，且该怪兽是否可以守备表示特殊召唤，并且种族符合要求。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsRace(race)
end
-- 效果处理的核心逻辑，包括检索10星怪兽、询问并执行丢弃手牌特殊召唤，以及适用特殊召唤限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsFaceup() or not tc:IsType(TYPE_MONSTER) then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只原本种族和对象怪兽相同的10星怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetOriginalRace())
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		local rc=g:GetFirst()
		-- 检查手牌中是否存在可丢弃的卡以及可特殊召唤的相同种族怪兽。
		if Duel.IsExistingMatchingCard(s.hdfilter,tp,LOCATION_HAND,0,1,nil,e,tp,rc:GetOriginalRace())
			-- 询问玩家是否适用后续的丢手牌特殊召唤效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			::cancel::
			-- 提示玩家选择要丢弃的手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 玩家选择1张要丢弃的手牌。
			local dg=Duel.SelectMatchingCard(tp,s.hdfilter,tp,LOCATION_HAND,0,0,1,nil,e,tp,rc:GetOriginalRace())
			local sg=nil
			if dg:GetCount()>0 then
				-- 提示玩家选择要特殊召唤的怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 玩家选择1只与加入手牌怪兽种族相同的怪兽进行特殊召唤（排除刚才选定要丢弃的卡）。
				sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,0,1,dg,e,tp,rc:GetOriginalRace())
				if #sg==0 then goto cancel end
			end
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			if dg:GetCount()>0 then
				-- 将选定的手牌丢弃送去墓地。
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
				if sg and sg:GetCount()>0 then
					-- 将选定的怪兽以守备表示特殊召唤到自己场上。
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
				end
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit(tc:GetOriginalRace()))
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该特殊召唤限制效果给玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：不能特殊召唤与指定种族不同的怪兽。
function s.splimit(race)
	return function(e,c)
			return not c:IsRace(race)
		end
end
