--墓守の偵察者
-- 效果：
-- 反转：从自己的卡组中特殊召唤1张攻击力1500以下名称中带有「守墓」的怪兽卡。
function c24317029.initial_effect(c)
	-- 反转：从自己的卡组中特殊召唤 1 张攻击力 1500 以下名称中带有「守墓」的怪兽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24317029,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c24317029.target)
	e1:SetOperation(c24317029.operation)
	c:RegisterEffect(e1)
end
-- 定义效果目标函数，初始化操作信息声明将从卡组特殊召唤 1 张怪兽
function c24317029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为特殊召唤类别，预计从卡组特殊召唤 1 张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义过滤条件，筛选攻击力 1500 以下、带有「守墓」字段且可被特殊召唤的怪兽
function c24317029.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数，执行场地检查、提示选择及特殊召唤逻辑
function c24317029.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区是否有可用空格，若无则终止效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择 1 张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c24317029.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
