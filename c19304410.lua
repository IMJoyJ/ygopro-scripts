--鉄獣の炎工 キット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「铁兽炎工 姬特」以外的，「铁兽」怪兽或「护宝炮妖」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。除「铁兽炎工 姬特」外的以下怪兽之内1只从自己墓地守备表示特殊召唤。
-- ●「铁兽」怪兽
-- ●「护宝炮妖」怪兽
-- ●「阿不思的落胤」或者有那个卡名记述的怪兽
local s,id,o=GetID()
-- 创建效果，注册两个效果：①从手卡特殊召唤；②被送去墓地时从墓地特殊召唤
function s.initial_effect(c)
	-- 记录该卡具有「阿不思的落胤」的卡名记述
	aux.AddCodeList(c,68468459)
	-- ①：自己场上有「铁兽炎工 姬特」以外的，「铁兽」怪兽或「护宝炮妖」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。除「铁兽炎工 姬特」外的以下怪兽之内1只从自己墓地守备表示特殊召唤。●「铁兽」怪兽●「护宝炮妖」怪兽●「阿不思的落胤」或者有那个卡名记述的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「铁兽」或「护宝炮妖」怪兽且不是姬特本身
function s.cfilter(c)
	return c:IsSetCard(0x14d,0x155) and c:IsFaceup() and not c:IsCode(id)
end
-- 效果条件函数，判断是否满足①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时点处理函数，判断是否可以发动
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，告知对方此效果将特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，将自身从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选墓地中可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id)
		-- 判断怪兽是否为「铁兽」或「护宝炮妖」，或是否记述了「阿不思的落胤」
		and (c:IsSetCard(0x14d,0x155) or aux.IsCodeOrListed(c,68468459))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动时点处理函数，判断是否可以发动
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足spfilter条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息，告知对方此效果将从墓地特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理函数，从墓地选择一只怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择一只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
