--真六武衆－カゲキ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「六武众」怪兽特殊召唤。
-- ②：自己场上有「真六武众-阴鬼」以外的「六武众」怪兽存在的场合，这张卡的攻击力上升1500。
function c2511717.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「六武众」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2511717,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c2511717.sptg)
	e1:SetOperation(c2511717.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「真六武众-阴鬼」以外的「六武众」怪兽存在的场合，这张卡的攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2511717.atkcon)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中等级4以下、卡名含「六武众」、且可以被特殊召唤的怪兽。
function c2511717.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断效果能否发动：自己主要怪兽区有空位，且手卡存在满足过滤条件的「六武众」怪兽。
function c2511717.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件且可以特殊召唤的「六武众」怪兽。
		and Duel.IsExistingMatchingCard(c2511717.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次效果处理信息设置为从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，选择手卡中1只满足条件的「六武众」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
function c2511717.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用的主要怪兽区空格，则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足过滤条件的「六武众」怪兽。
	local g=Duel.SelectMatchingCard(tp,c2511717.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断怪兽是否为表侧表示、卡名含「六武众」、且不是「真六武众-阴鬼」本身。
function c2511717.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(2511717)
end
-- 攻击力上升条件：自己场上有「真六武众-阴鬼」以外的表侧表示「六武众」怪兽存在。
function c2511717.atkcon(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只符合条件的其他「六武众」怪兽。
	return Duel.IsExistingMatchingCard(c2511717.atkfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
