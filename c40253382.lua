--TG－SX1
-- 效果：
-- 自己场上存在的名字带有「科技属」的怪兽战斗破坏对方怪兽送去墓地时才能发动。选择自己墓地存在的1只名字带有「科技属」的同调怪兽特殊召唤。
function c40253382.initial_effect(c)
	-- 自己场上存在的名字带有「科技属」的怪兽战斗破坏对方怪兽送去墓地时才能发动。选择自己墓地存在的1只名字带有「科技属」的同调怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c40253382.condition)
	e1:SetTarget(c40253382.target)
	e1:SetOperation(c40253382.activate)
	c:RegisterEffect(e1)
end
-- 筛选被战斗破坏并送去墓地的怪兽：该怪兽位于墓地且是被战斗破坏，造成其破坏的怪兽是自己场上（控制者为tp）的名字带有「科技属」的怪兽，并且该破坏来源怪兽与本次战斗相关。
function c40253382.cfilter(c,tp)
	local rc=c:GetReasonCard()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and rc:IsSetCard(0x27) and rc:IsControler(tp) and rc:IsRelateToBattle()
end
-- 发动条件判定：本次战斗中是否至少存在1只被自己场上科技属怪兽战斗破坏并送去墓地的对方怪兽。
function c40253382.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40253382.cfilter,1,nil,tp)
end
-- 筛选可特殊召唤的卡：墓地中满足名字带有「科技属」且为同调怪兽，并且可以被玩家tp以表侧表示特殊召唤。
function c40253382.filter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择效果对象的流程：先验证对象卡是否合法（在墓地、自己控制、满足filter），再检查自己场上是否有空位、墓地是否存在1只以上符合条件的科技属同调怪兽，随后选择1个目标。
function c40253382.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40253382.filter(chkc,e,tp) end
	-- 发动时检查自己主要怪兽区域是否有可用空格，确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只符合条件的科技属同调怪兽可以作为特殊召唤的对象。
		and Duel.IsExistingTarget(c40253382.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的科技属同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c40253382.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次操作信息登记为特殊召唤，对象为已选择的目标，数量为1，使相关时点/检测能够正确识别。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时：取出连锁上选择的目标，确认该目标仍与效果相关联后，将其正面表示特殊召唤到自己场上。
function c40253382.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
