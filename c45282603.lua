--召喚師セームベル
-- 效果：
-- 自己的主要阶段时，可以把和这张卡相同等级的1只怪兽从手卡特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c45282603.initial_effect(c)
	-- 效果原文：自己的主要阶段时，可以把和这张卡相同等级的1只怪兽从手卡特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45282603,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(c45282603.sptg)
	e1:SetOperation(c45282603.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡中是否存在等级与当前怪兽相同且可以特殊召唤的怪兽。
function c45282603.filter(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件。
function c45282603.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的怪兽（等级相同且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c45282603.filter,tp,LOCATION_HAND,0,1,nil,e:GetHandler():GetLevel(),e,tp) end
	-- 设置效果处理时的操作信息，表明将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作。
function c45282603.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否还有空位，若无则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的怪兽（等级相同且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c45282603.filter,tp,LOCATION_HAND,0,1,1,nil,e:GetHandler():GetLevel(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
