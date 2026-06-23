--超力の聖刻印
-- 效果：
-- 从手卡把1只名字带有「圣刻」的怪兽特殊召唤。
function c51365514.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，可以自由连锁，目标函数为c51365514.target，处理函数为c51365514.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51365514.target)
	e1:SetOperation(c51365514.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中名字带有「圣刻」且可以特殊召唤的怪兽
function c51365514.filter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，检查是否满足发动条件：场上存在空位并且手牌中有符合条件的怪兽
function c51365514.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在至少1张名字带有「圣刻」且可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c51365514.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽到玩家场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的具体处理函数，判断是否满足特殊召唤条件并执行召唤操作
function c51365514.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家场上是否有可用的怪兽区域，若无则返回不执行召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家手牌中选择1张符合条件的怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c51365514.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到玩家场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
