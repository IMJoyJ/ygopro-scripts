--前線基地
-- 效果：
-- 1回合1次，自己的主要阶段时可以从手卡把1只4星以下的同盟怪兽特殊召唤。
function c46181000.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：1回合1次，自己的主要阶段时可以从手卡把1只4星以下的同盟怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46181000,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(c46181000.target)
	e1:SetOperation(c46181000.operation)
	c:RegisterEffect(e1)
end
c46181000.has_text_type=TYPE_UNION
-- 检索满足条件的卡片组：同盟怪兽且等级不超过4星，并且可以被特殊召唤
function c46181000.filter(c,e,sp)
	return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 判断是否可以发动此效果：场上存在空位并且手牌中有符合条件的怪兽
function c46181000.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽数量
		and Duel.IsExistingMatchingCard(c46181000.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡牌数量和来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：执行特殊召唤操作
function c46181000.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的一张怪兽
	local g=Duel.SelectMatchingCard(tp,c46181000.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
