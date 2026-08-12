--キングス・ナイト
-- 效果：
-- ①：自己场上有「王后骑士」存在，这张卡召唤成功时才能发动。从卡组把1只「卫兵骑士」特殊召唤。
function c64788463.initial_effect(c)
	-- 将「王后骑士」和「卫兵骑士」的卡片密码注册到本卡的关联卡片列表中。
	aux.AddCodeList(c,25652259,90876561)
	-- ①：自己场上有「王后骑士」存在，这张卡召唤成功时才能发动。从卡组把1只「卫兵骑士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64788463,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c64788463.spcon)
	e1:SetTarget(c64788463.sptg)
	e1:SetOperation(c64788463.spop)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：表侧表示的「王后骑士」。
function c64788463.cfilter(c)
	return c:IsFaceup() and c:IsCode(25652259)
end
-- 定义效果发动条件：自己场上有「王后骑士」存在。
function c64788463.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「王后骑士」。
	return Duel.IsExistingMatchingCard(c64788463.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义过滤条件：卡组中可以被特殊召唤的「卫兵骑士」。
function c64788463.filter(c,e,tp)
	return c:IsCode(90876561) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动目标：检查怪兽区域空位和卡组中是否存在可特殊召唤的「卫兵骑士」，并设置特殊召唤的操作信息。
function c64788463.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中是否存在至少1只可以特殊召唤的「卫兵骑士」。
		and Duel.IsExistingMatchingCard(c64788463.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理：从卡组将1只「卫兵骑士」特殊召唤。
function c64788463.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的主要怪兽区域，则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「卫兵骑士」。
	local g=Duel.SelectMatchingCard(tp,c64788463.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
