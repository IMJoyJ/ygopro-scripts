--奇跡の残照
-- 效果：
-- ①：以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c21636650.initial_effect(c)
	-- 效果原文内容：①：以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c21636650.sptg)
	e1:SetOperation(c21636650.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：该卡片为本回合被战斗破坏且在墓地的怪兽，且可以特殊召唤
function c21636650.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and bit.band(c:GetReason(),REASON_BATTLE)~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足特殊召唤条件，包括卡片位置、控制者、是否为本回合被战斗破坏以及是否可以特殊召唤
function c21636650.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果作用：获取当前回合数，用于判断卡片是否为本回合被战斗破坏
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21636650.filter(chkc,e,tp,tid) end
	-- 效果作用：判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c21636650.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 效果作用：向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c21636650.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 效果作用：设置当前连锁的操作信息，确定要特殊召唤的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c21636650.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
