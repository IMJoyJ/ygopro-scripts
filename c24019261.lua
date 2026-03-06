--救急救命
-- 效果：
-- 主要阶段2才能发动。这个回合被卡的效果破坏送去墓地的1只4星的怪兽从自己墓地特殊召唤。
function c24019261.initial_effect(c)
	-- 创建效果，设置为魔陷发动，可取对象，自由连锁，条件为主要阶段2，目标为特殊召唤，效果处理为发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c24019261.condition)
	e1:SetTarget(c24019261.target)
	e1:SetOperation(c24019261.activate)
	c:RegisterEffect(e1)
end
-- 主要阶段2才能发动
function c24019261.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤满足条件的墓地怪兽：被卡的效果破坏且在本回合被破坏，等级为4，且可特殊召唤
function c24019261.filter(c,e,tp,tid)
	return bit.band(c:GetReason(),0x41)==0x41 and c:GetTurnID()==tid
		and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查是否有满足条件的墓地怪兽可特殊召唤
function c24019261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24019261.filter(chkc,e,tp,tid) end
	-- 检查场上是否有空位且墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c24019261.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c24019261.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的怪兽特殊召唤
function c24019261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
