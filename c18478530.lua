--ローゲの焔
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在并在自己场上有「女武神」怪兽存在，攻击力2000以下的对方怪兽不能攻击。
-- ②：这张卡被对方的效果破坏的场合才能发动。从手卡·卡组把1只5星以上的「女武神」怪兽特殊召唤。
function c18478530.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在并在自己场上有「女武神」怪兽存在，攻击力2000以下的对方怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c18478530.condition)
	e2:SetTarget(c18478530.atktarget)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方的效果破坏的场合才能发动。从手卡·卡组把1只5星以上的「女武神」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c18478530.spcon)
	e3:SetTarget(c18478530.sptg)
	e3:SetOperation(c18478530.spop)
	c:RegisterEffect(e3)
end
-- 检查是否为表侧表示且属于「女武神」字段（0x122）的怪兽。
function c18478530.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- ①效果的生效条件：自己场上存在表侧表示的「女武神」怪兽。
function c18478530.condition(e)
	-- 检查自己的主要怪兽区是否存在至少1只表侧表示的「女武神」怪兽。
	return Duel.IsExistingMatchingCard(c18478530.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判定对象怪兽的攻击力是否为2000以下（是则受到“不能攻击”限制）。
function c18478530.atktarget(e,c)
	return c:IsAttackBelow(2000)
end
-- ②的发动条件：这张卡被对方的效果破坏（破坏原因同时包含“破坏”和“效果”，且效果控制者为对方）。
function c18478530.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp
end
-- 筛选可特殊召唤的5星以上「女武神」怪兽：满足字段、等级与特殊召唤条件。
function c18478530.filter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②发动时的目标条件：自己主要怪兽区有空位，且手卡·卡组中存在符合条件的「女武神」怪兽。
function c18478530.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）先确认自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认手卡·卡组中是否存在1只以上满足筛选条件的「女武神」怪兽。
		and Duel.IsExistingMatchingCard(c18478530.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从手卡·卡组把1只「女武神」怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：从手卡·卡组选择1只5星以上的「女武神」怪兽，以表侧攻击表示特殊召唤到自己场上。
function c18478530.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组选择1只满足条件的「女武神」怪兽。
	local g=Duel.SelectMatchingCard(tp,c18478530.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
