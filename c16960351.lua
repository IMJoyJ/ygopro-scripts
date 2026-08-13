--幻界突破
-- 效果：
-- ①：1回合1次，把自己场上1只龙族怪兽解放才能发动。和解放的怪兽的原本等级相同等级的1只幻龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
function c16960351.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1只龙族怪兽解放才能发动。和解放的怪兽的原本等级相同等级的1只幻龙族怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16960351,0))  --"「幻界突破」效果适用中"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c16960351.spcost)
	e2:SetTarget(c16960351.sptg)
	e2:SetOperation(c16960351.spop)
	c:RegisterEffect(e2)
end
-- 筛选可作为解放代价的龙族怪兽：要求原本等级大于0、种族为龙族，并考虑我方主要怪兽区空位（若空位不足则只能选择我方的额外怪兽区/或对方场上表侧表示的龙族等情况），且卡组中存在与解放怪兽原本等级相同、可特殊召唤的幻龙族怪兽。
function c16960351.rfilter(c,e,tp,ft)
	local lv=c:GetOriginalLevel()
	return lv>0 and c:IsRace(RACE_DRAGON)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 确认卡组中存在1只满足条件的幻龙族怪兽，以此作为该效果能否发动的额外前提条件。
		and Duel.IsExistingMatchingCard(c16960351.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 筛选卡组中与指定等级相同、种族为幻龙族且可以被效果特殊召唤的怪兽。
function c16960351.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价处理：检查并选择1只可解放的龙族怪兽，记录其原本等级作为后续特殊召唤的等级依据，然后将其解放作为发动代价。
function c16960351.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前我方主要怪兽区的可用空位数，用于判断解放并特殊召唤后是否有位置放置怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动合法性检查：要求我方主要怪兽区空位大于-1（解放怪兽后至少能空出1个位置），并且场上存在1只可解放的龙族怪兽且卡组有对应幻龙族怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c16960351.rfilter,1,nil,e,tp,ft) end
	-- 从场上选择1只符合条件的龙族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c16960351.rfilter,1,1,nil,e,tp,ft)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalLevel())
	-- 将选择的怪兽解放，解放作为效果的发动代价处理。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤的目标处理：效果发动时直接允许，并在操作信息中登记将进行特殊召唤，处理时再选择要召唤的怪兽。
function c16960351.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息登记为“从卡组把1只怪兽特殊召唤”，供相关卡牌效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤处理：取出代价阶段记录的原本等级，从卡组选择符合条件的幻龙族怪兽表侧表示特殊召唤，并给那只怪兽附加战斗破坏的怪兽不去墓地而回到持有者卡组的效果。
function c16960351.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与记录的原本等级相同、种族为幻龙族且可以特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c16960351.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查苏生限制，不检查召唤条件）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
