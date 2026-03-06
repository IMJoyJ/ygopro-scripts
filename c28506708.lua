--ワーム・コール
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只名字带有「异虫」的爬虫类族怪兽里侧守备表示特殊召唤。这个效果1回合只能使用1次。
function c28506708.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：对方场上有怪兽存在，自己场上没有怪兽存在的场合，可以从手卡把1只名字带有「异虫」的爬虫类族怪兽里侧守备表示特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28506708,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c28506708.condition)
	e1:SetTarget(c28506708.target)
	e1:SetOperation(c28506708.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对方场上存在怪兽，自己场上不存在怪兽
function c28506708.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上不存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 效果作用：检查对方场上存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 效果作用：过滤满足条件的怪兽（异虫族、爬虫类族、可特殊召唤）
function c28506708.filter(c,e,sp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,sp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果作用：判断是否满足发动条件（场上存在可特殊召唤的怪兽）
function c28506708.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c28506708.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：发动时再次检查召唤条件
function c28506708.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：检查自己场上是否存在怪兽
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 效果作用：检查对方场上是否存在怪兽
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c28506708.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 效果作用：确认对方查看特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
