--マシンナーズ・ソルジャー
-- 效果：
-- ①：自己场上没有其他怪兽存在，这张卡召唤成功时才能发动。从手卡把「机甲士兵」以外的1只「机甲」怪兽特殊召唤。
function c60999392.initial_effect(c)
	-- ①：自己场上没有其他怪兽存在，这张卡召唤成功时才能发动。从手卡把「机甲士兵」以外的1只「机甲」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60999392,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c60999392.sumcon)
	e1:SetTarget(c60999392.sumtg)
	e1:SetOperation(c60999392.sumop)
	c:RegisterEffect(e1)
end
-- 定义发动条件：自己场上没有其他怪兽存在
function c60999392.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否刚好为1（即只有刚召唤成功的这张卡本身，没有其他怪兽）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 过滤条件：手卡中「机甲士兵」以外的「机甲」怪兽，且该怪兽可以被特殊召唤
function c60999392.filter(c,e,tp)
	return c:IsSetCard(0x36) and not c:IsCode(60999392) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动目标：检查自己场上是否有空位，以及手卡中是否存在符合条件的怪兽
function c60999392.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c60999392.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理：从手卡选择1只符合条件的「机甲」怪兽特殊召唤
function c60999392.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「机甲」怪兽
	local g=Duel.SelectMatchingCard(tp,c60999392.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
