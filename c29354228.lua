--ドラグマ・エンカウンター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只「教导」怪兽或「阿不思的落胤」特殊召唤。
-- ●从自己墓地选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c29354228.initial_effect(c)
	-- 将「阿不思的落胤」（68468459）的卡号登记到本卡的代码列表中，表示这张卡的效果文记载了该卡名，用于相关判定与检索。
	aux.AddCodeList(c,68468459)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从手卡把1只「教导」怪兽或「阿不思的落胤」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29354228,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,29354228+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29354228.sptg)
	e1:SetOperation(c29354228.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从自己墓地选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29354228,1))  --"从墓地加入手卡或特殊召唤"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,29354228+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c29354228.thtg)
	e2:SetOperation(c29354228.thop)
	c:RegisterEffect(e2)
end
-- 筛选可用于特殊召唤的手牌卡：该卡必须是「教导」怪兽（0x145）或「阿不思的落胤」（68468459），并且满足特殊召唤条件。
function c29354228.spfilter(c,e,tp)
	return (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第一个效果的发动条件判定：检查自己场上主要怪兽区是否有空位，且手牌中存在满足spfilter条件的可特殊召唤的卡。
function c29354228.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足spfilter条件且可选择特殊召唤的卡。
		and Duel.IsExistingMatchingCard(c29354228.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示本次发动选择的是哪个效果（显示对应效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果处理将把手牌中的1只怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 第一个效果的处理：从手牌选择1只符合条件的「教导」怪兽或「阿不思的落胤」，以表侧表示特殊召唤到自己的主要怪兽区。
function c29354228.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上主要怪兽区已无空位，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1张满足spfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c29354228.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择成功的卡以表侧攻击表示特殊召唤到自己的主要怪兽区（无视召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选墓地里可作为对象的卡：该卡必须是「教导」怪兽或「阿不思的落胤」，并且能够加入手卡，或（场上空位足够时）可以特殊召唤。
function c29354228.thfilter(c,e,tp)
	if not (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 取得自己场上主要怪兽区可用空位数量，用于后续判断该卡能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 第二个效果的发动条件判定：确认墓地存在满足thfilter条件的卡，并设置回手/特殊召唤相关的操作信息。
function c29354228.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少1张满足thfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c29354228.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示本次发动选择的是哪个效果（显示对应效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果处理可能从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：本次效果处理可能从墓地加入1张卡到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 第二个效果的处理：从墓地选择1张符合条件的卡，在可加入手卡或可特殊召唤时由玩家选择其一并执行。
function c29354228.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要操作的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从墓地中选择1张满足thfilter条件且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29354228.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 取得自己场上主要怪兽区可用空位数量，用于判断选择的卡能否特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否为加入手卡：若选中的卡可以加入手卡，并且（不能特殊召唤、或场上无空位、或玩家选择了“加入手卡”选项）时，执行回手处理；否则执行特殊召唤。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的卡以效果原因送回到持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡，使其信息公开。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡以表侧攻击表示特殊召唤到自己的主要怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
