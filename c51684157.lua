--天幻の龍輪
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡把效果无效特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「天威」卡加入手卡。
function c51684157.initial_effect(c)
	-- ①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡把效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51684157,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,51684157)
	e1:SetCost(c51684157.cost)
	e1:SetTarget(c51684157.target)
	e1:SetOperation(c51684157.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「天威」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51684157,1))
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51684157)
	e2:SetCondition(c51684157.thcon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（借助辅助函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51684157.thtg)
	e2:SetOperation(c51684157.thop)
	c:RegisterEffect(e2)
end
-- 定义解放用滤筛：可作为解放的怪兽必须是幻龙族，且卡组中存在能加入手卡的幻龙族；若解放的是效果怪兽以外的怪兽且走特殊召唤分支，则还需卡组存在可特殊召唤的幻龙族且解放后我方仍有空余怪兽区。
function c51684157.filter(c,e,tp,check)
	-- 检查被解放怪兽为幻龙族，并且卡组中存在可通过通常检索加入手卡的幻龙族目标。
	return c:IsRace(RACE_WYRM) and (Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		or (check and not c:IsType(TYPE_EFFECT)
		-- 当解放的是效果怪兽以外的怪兽时（check为真），检查卡组中是否存在可以特殊召唤的幻龙族目标。
		and Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true)
		-- 确认解放该怪兽后自己场上仍有可用怪兽区，以满足后续特殊召唤条件。
		and Duel.GetMZoneCount(tp,c)>0))
end
-- 定义检索目标滤筛：目标为幻龙族，且可以加入手卡；或在check模式下可以特殊召唤。
function c51684157.thfilter(c,e,tp,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 定义效果处理阶段选卡滤筛：目标为幻龙族，可加入手卡；或在特殊召唤分支下可特殊召唤且我方怪兽区有空位。
function c51684157.thfilter2(c,e,tp,ft,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
-- 定义①效果的发动代价：从自己场上选择并解放1只满足条件的幻龙族怪兽；若解放的不是效果怪兽，则用标记记录，以便处理时选择特殊召唤分支。
function c51684157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 在发动合法性检查（chk==0）时，确认自己场上存在至少1只可作为解放的幻龙族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51684157.filter,1,nil,e,tp,true) end
	-- 向玩家显示“请选择要解放的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足filter条件的幻龙族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c51684157.filter,1,1,nil,e,tp,true)
	if not g:GetFirst():IsType(TYPE_EFFECT) then e:SetLabel(100,1) end
	-- 将选中的怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义①效果的发动目标与操作信息：根据cost阶段是否解放了效果怪兽以外的怪兽来决定是否启用特殊召唤分支；并检查卡组中有无对应目标的幻龙族怪兽。
function c51684157.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=true
	local l1,l2=e:GetLabel()
	if chk==0 then
		if l1~=100 then check=false end
		e:SetLabel(0,0)
		-- 发动合法性检查：确认卡组中存在满足条件的幻龙族目标（可加入手卡或在特殊召唤分支下可特殊召唤）。
		return Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
	if l2==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置操作信息：效果处理时将从卡组把1张卡加入手卡（用于通常检索分支）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	end
end
-- 定义①效果处理逻辑：若未使用特殊召唤分支则检索加入手卡；若使用了特殊召唤分支，则从卡组特殊召唤1只幻龙族怪兽并使其效果无效。
function c51684157.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local check=false
	local l1,l2=e:GetLabel()
	if l2==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then check=true end
	-- 获取自己场上当前可用的怪兽区数量，用于判断是否能够进行特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1只满足thfilter2条件的幻龙族怪兽（可加入手卡或可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c51684157.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft,check)
	local tc=g:GetFirst()
	if tc then
		if not check or (tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当玩家选择加入手卡分支时（无法特殊召唤或玩家主动选择加入手卡）执行送入手卡。
			or Duel.SelectOption(tp,1190,1152)==0)) then
			-- 将选中的幻龙族怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的那张卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 尝试将选中的幻龙族怪兽以表侧表示特殊召唤（分解步骤）。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 对应①效果中『也能不加入手卡把效果无效特殊召唤』的『效果无效』部分：让特殊召唤的怪兽效果无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 继续对应『把效果无效特殊召唤』的『效果无效』：使该怪兽的效果无效且本回合不能发动效果。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤处理（SpecialSummonStep的收尾）。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 定义②效果的条件滤筛：怪兽为表侧表示且不是效果怪兽。
function c51684157.ffilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 定义②效果的发动条件：自己场上有表侧表示且不是效果怪兽的怪兽存在。
function c51684157.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足ffilter条件的怪兽。
	return Duel.IsExistingMatchingCard(c51684157.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果的检索滤筛：卡名含有「天威」字段且可以加入手卡的卡。
function c51684157.cfilter(c)
	return c:IsSetCard(0x12c) and c:IsAbleToHand()
end
-- 定义②效果的发动目标与操作信息：从卡组检索1张「天威」卡加入手卡。
function c51684157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在可加入手卡的「天威」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c51684157.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将从卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果处理：从卡组选择1张「天威」卡加入手卡，并向对方确认。
function c51684157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足cfilter条件的「天威」卡。
	local g=Duel.SelectMatchingCard(tp,c51684157.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「天威」卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
