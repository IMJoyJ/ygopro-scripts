--真六武衆－カゲキ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「六武众」怪兽特殊召唤。
-- ②：自己场上有「真六武众-阴鬼」以外的「六武众」怪兽存在的场合，这张卡的攻击力上升1500。
function c2511717.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。从手卡把1只4星以下的「六武众」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2511717,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c2511717.sptg)
	e1:SetOperation(c2511717.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上有「真六武众-阴鬼」以外的「六武众」怪兽存在的场合，这张卡的攻击力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2511717.atkcon)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中满足条件的「六武众」怪兽（等级4以下且可特殊召唤）
function c2511717.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件（场地有空位且手卡有符合条件的怪兽）
function c2511717.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断目标玩家手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c2511717.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽到目标玩家场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c2511717.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示目标玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从目标玩家手卡中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2511717.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选场上符合条件的「六武众」怪兽（正面表示且不是本卡）
function c2511717.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(2511717)
end
-- 判断是否满足攻击力上升条件（自己场上有其他「六武众」怪兽）
function c2511717.atkcon(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在其他「六武众」怪兽
	return Duel.IsExistingMatchingCard(c2511717.atkfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
