--奇跡の残照
-- 效果：
-- ①：以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c21636650.initial_effect(c)
	-- ①：以这个回合被战斗破坏送去自己墓地的1只怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 定义筛选函数：选择本回合（tid）被战斗破坏（reason含REASON_BATTLE）且可以特殊召唤的自己墓地的怪兽。
function c21636650.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and bit.band(c:GetReason(),REASON_BATTLE)~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择与发动合法性判定：检查是否存在符合条件的墓地怪兽，且可将其作为对象；若为发动时点，还需确认自己场上存在可用的主要怪兽区域空格。
function c21636650.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数tid，用于判断怪兽是否是在“这个回合”被战斗破坏送去墓地。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21636650.filter(chkc,e,tp,tid) end
	-- 非处理阶段（chk==0）检查自己主要怪兽区是否有空格，确保特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在至少1只满足筛选条件的墓地怪兽可作为效果对象（即进行取对象的存在性检查）。
		and Duel.IsExistingTarget(c21636650.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 向发动玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己墓地选择1只符合条件的怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c21636650.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 登记效果处理信息：本次处理将进行特殊召唤，对象为已选择的1张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取效果对象，确认其仍与该效果关联后，将其特殊召唤到自己场上。
function c21636650.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以表侧表示特殊召唤到自己的主要怪兽区（不忽略召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
