--インフェルニティ・リフレクター
-- 效果：
-- 自己场上存在的名字带有「永火」的怪兽被战斗破坏送去墓地时，把手卡全部丢弃才能发动。那1只怪兽从自己墓地特殊召唤，给与对方基本分1000分伤害。
function c15313433.initial_effect(c)
	-- 效果原文内容：自己场上存在的名字带有「永火」的怪兽被战斗破坏送去墓地时，把手卡全部丢弃才能发动。那1只怪兽从自己墓地特殊召唤，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c15313433.cost)
	e1:SetTarget(c15313433.target)
	e1:SetOperation(c15313433.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查手牌是否满足丢弃条件并执行丢弃操作
function c15313433.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：获取玩家手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 效果作用：将手牌全部送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义可被选择的墓地中的永火怪兽过滤条件
function c15313433.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置连锁处理的目标选择和操作信息
function c15313433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c15313433.filter(chkc,e,tp) end
	-- 效果作用：判断场上是否存在满足条件的墓地怪兽且是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c15313433.filter,1,nil,e,tp) end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c15313433.filter,1,1,nil,e,tp)
	-- 效果作用：设置当前连锁处理的目标卡
	Duel.SetTargetCard(g)
	-- 效果作用：设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 效果作用：设置造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,1000)
end
-- 效果作用：执行效果的处理流程，包括特殊召唤和造成伤害
function c15313433.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 效果作用：对对方造成1000点伤害
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
