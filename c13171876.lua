--ドラゴンメイド・ラドリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己卡组上面把3张卡送去墓地。
-- ②：自己·对方的战斗阶段开始时才能发动。场上的这张卡回到手卡，从自己的手卡·墓地把1只7星「半龙女仆」怪兽特殊召唤。
function c13171876.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
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
	-- ②：自己·对方的战斗阶段开始时才能发动。
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
-- 效果处理函数ddtg的定义
function c13171876.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以将自己卡组最上面3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置连锁操作信息，表示将要从自己卡组上面把3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果处理函数ddop的定义
function c13171876.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上面3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
-- 筛选符合条件的7星半龙女仆怪兽的过滤函数定义
function c13171876.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数sptg的定义
function c13171876.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己手卡或墓地是否存在至少1只7星「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c13171876.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要将这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置连锁操作信息，表示将要从自己手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数spop的定义
function c13171876.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否还在场上且成功送回手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 检查自己场上是否有可用的怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的1只7星「半龙女仆」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13171876.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
