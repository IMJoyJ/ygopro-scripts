--ドラゴンメイド・ラドリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡送去墓地。
-- ②：自己·对方的战斗阶段开始时才能发动。场上的这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
function c13171876.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13171876,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,13171876)
	e1:SetTarget(c13171876.ddtg)
	e1:SetOperation(c13171876.ddop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动。场上的这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13171876,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13171877)
	e3:SetTarget(c13171876.sptg)
	e3:SetOperation(c13171876.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件与操作信息设置：检查能否从卡组顶丢弃3张卡，并登记“从卡组上方丢弃3张卡”的操作信息。
function c13171876.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查当前玩家是否能从卡组最上方把3张卡送去墓地，不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置操作信息：本次效果涉及将当前玩家卡组最上方3张卡送去墓地，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- ①效果处理：实际从自己卡组上面把3张卡送去墓地。
function c13171876.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将当前玩家卡组最上方3张卡送去墓地。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
-- 定义可特殊召唤的怪兽过滤条件：必须是7星且字段为「半龙女仆」、并能被当前效果特殊召唤。
function c13171876.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件：这张卡自身可以被送回手牌、自己场上有空余怪兽区、并且手卡·墓地存在可特殊召唤的7星「半龙女仆」怪兽。
function c13171876.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 确认若这张卡回到手牌后，自己场上仍拥有可用的怪兽区，用于后续特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
		-- 确认手卡·墓地中存在至少1只可被特殊召唤的7星「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c13171876.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时这张卡将返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：效果处理时将进行1只怪兽的特殊召唤，候选区域为手卡·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：将这张卡返回手牌；成功返回后，从手卡·墓地选择1只7星「半龙女仆」怪兽表侧表示特殊召唤。
function c13171876.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与当前效果关联，并执行返回手牌；只有返回成功才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡确实在手牌，且自己场上有可用的怪兽区，用于特殊召唤。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家显示选择提示，要求其选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只满足过滤条件且不受王家长眠之谷影响的7星「半龙女仆」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13171876.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
