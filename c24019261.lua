--救急救命
-- 效果：
-- 主要阶段2才能发动。这个回合被卡的效果破坏送去墓地的1只4星的怪兽从自己墓地特殊召唤。
function c24019261.initial_effect(c)
	-- 主要阶段2才能发动。这个回合被卡的效果破坏送去墓地的1只4星的怪兽从自己墓地特殊召唤。
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
-- 效果发动条件判断：当前阶段为主要阶段2时，才允许发动该效果。
function c24019261.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段2（PHASE_MAIN2），是则满足条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 筛选墓地中的候选怪兽：必须是被卡的效果破坏（原因含0x41：破坏+效果）、在本回合被送入墓地、等级为4且能够被当前效果特殊召唤。
function c24019261.filter(c,e,tp,tid)
	return bit.band(c:GetReason(),0x41)==0x41 and c:GetTurnID()==tid
		and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择处理：记录当前回合数；检查选择对象是否合法（我方墓地、满足筛选条件）；在发动时确认我方怪兽区有空位且墓地存在至少1只符合条件的4星怪兽。
function c24019261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于筛选出“这个回合”被破坏送去墓地的怪兽。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24019261.filter(chkc,e,tp,tid) end
	-- 发动判定中，确认我方主要怪兽区域是否有可用的空格；若无空格则不能发动特召效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查墓地是否存在满足‘本回合被效果破坏、4星、可特召’条件的怪兽，存在1只以上才允许发动。
		and Duel.IsExistingTarget(c24019261.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) end
	-- 给出选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的4星怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c24019261.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	-- 登记当前连锁的操作信息：本次将进行特殊召唤，对象为所选的1只怪兽，供后续处理时点判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取得对象怪兽，若其仍与效果关联则将其表侧表示特殊召唤到自己场上。
function c24019261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁登记的第一张对象卡，即之前选择的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上，完成特殊召唤处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
