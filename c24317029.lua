--墓守の偵察者
-- 效果：
-- 反转：从自己的卡组中特殊召唤1张攻击力1500以下名称中带有「守墓」的怪兽卡。
function c24317029.initial_effect(c)
	-- 反转：从自己的卡组中特殊召唤1张攻击力1500以下名称中带有「守墓」的怪兽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24317029,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c24317029.target)
	e1:SetOperation(c24317029.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c24317029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要特殊召唤1张卡到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选攻击力1500以下且带有「守墓」字段的怪兽卡
function c24317029.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理
function c24317029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c24317029.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
