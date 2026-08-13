--憶念の相剣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：卡被除外的场合才能发动。从自己的手卡·卡组·墓地以及自己·对方场上的表侧表示卡之中把1只幻龙族同调怪兽或者1张「相剑」卡除外。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
function c99137266.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：卡被除外的场合才能发动。从自己的手卡·卡组·墓地以及自己·对方场上的表侧表示卡之中把1只幻龙族同调怪兽或者1张「相剑」卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99137266,0))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,99137266)
	e2:SetTarget(c99137266.remtg)
	e2:SetOperation(c99137266.remop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合才能发动。在自己场上把1只「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）特殊召唤。只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99137266,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,99137267)
	e3:SetTarget(c99137266.sptg)
	e3:SetOperation(c99137266.spop)
	c:RegisterEffect(e3)
end
-- 定义可选对象的过滤条件：是幻龙族同调怪兽或「相剑」卡，且能够被除外；若在场上则必须是表侧表示。
function c99137266.rmfilter(c)
	return (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_WYRM) or c:IsSetCard(0x16b))
		and c:IsAbleToRemove() and (c:IsFaceup() or not c:IsOnField())
end
-- ①效果发动时的条件检测与操作信息登记：收集所有符合条件的候选卡，若存在则满足发动条件，并设置除外1张的操作信息。
function c99137266.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己的手牌·场上·墓地·卡组以及对方场上的表侧表示卡中，获取所有满足过滤条件的卡片集合。
	local g=Duel.GetMatchingGroup(c99137266.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置本次效果处理将进行除外操作，对象为候选集合g，预计除外1张，位置涵盖手牌·场上·墓地·卡组。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果处理：提示选择要除外的卡，从指定范围选择1张符合条件的卡，将其除外。
function c99137266.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手牌·场上·墓地·卡组以及对方场上的表侧表示卡中选择1张符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c99137266.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 将选中的卡片以表侧表示除外，除外原因视为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果发动条件：自己场上的主要怪兽区有空位，且自己能够特殊召唤「相剑衍生物」。
function c99137266.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上的主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己能否特殊召唤「相剑衍生物」（幻龙族·调整·水·4星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置本次效果处理将生成衍生物，预计数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次效果处理将进行特殊召唤，预计数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：若主怪兽区有空位且能特殊召唤衍生物，则生成token并特殊召唤，同时给token附加“存在期间自己不能从额外卡组特殊召唤非同步怪兽”的限制效果。
function c99137266.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次确认自己场上主要怪兽区是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理阶段再次确认能否特殊召唤该衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20001444,0x16b,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,4,RACE_WYRM,ATTRIBUTE_WATER) then
		-- 生成1只「相剑衍生物」（token）到自己场上。
		local token=Duel.CreateToken(tp,99137267)
		-- 以特殊召唤步骤将token正面表示特殊召唤到自己场上。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 只要这个效果特殊召唤的衍生物存在，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c99137266.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成整个特殊召唤处理（与SpecialSummonStep配套使用）。
		Duel.SpecialSummonComplete()
	end
end
-- 限制效果的判定：若卡片来自额外卡组且不是同调怪兽，则禁止特殊召唤。
function c99137266.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
