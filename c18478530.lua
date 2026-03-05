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
	-- 效果原文内容：①：只要这张卡在魔法与陷阱区域存在并在自己场上有「女武神」怪兽存在，攻击力2000以下的对方怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c18478530.condition)
	e2:SetTarget(c18478530.atktarget)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡被对方的效果破坏的场合才能发动。从手卡·卡组把1只5星以上的「女武神」怪兽特殊召唤。
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
-- 过滤函数：检查场上是否存在「女武神」怪兽
function c18478530.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- 条件函数：判断自己场上是否存在「女武神」怪兽
function c18478530.condition(e)
	-- 检查以自己来看的场上是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c18478530.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 目标函数：判断目标怪兽攻击力是否低于2000
function c18478530.atktarget(e,c)
	return c:IsAttackBelow(2000)
end
-- 发动条件函数：判断此卡被对方效果破坏
function c18478530.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp
end
-- 过滤函数：检查手卡或卡组中是否存在满足条件的「女武神」怪兽
function c18478530.filter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的处理函数：判断是否满足特殊召唤条件
function c18478530.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组中是否存在满足条件的「女武神」怪兽
		and Duel.IsExistingMatchingCard(c18478530.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只「女武神」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数：执行特殊召唤操作
function c18478530.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「女武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c18478530.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
