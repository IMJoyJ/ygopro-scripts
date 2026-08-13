--ロードポイズン
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己墓地里特殊召唤1只「毒根王」以外的植物族怪兽上场。
function c40320754.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从自己墓地里特殊召唤1只「毒根王」以外的植物族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40320754,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c40320754.condition)
	e1:SetTarget(c40320754.target)
	e1:SetOperation(c40320754.operation)
	c:RegisterEffect(e1)
end
-- 判断诱发条件：效果持有者（这张卡）当前位于墓地，且是被战斗破坏（含因此送去墓地的过程）的场合，满足则本效果可发动。
function c40320754.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义可特殊召唤的卡牌筛选条件：对象必须是植物族、不是「毒根王」（卡号40320754）、且能被当前效果正常特殊召唤（检查召唤条件与苏生限制）。
function c40320754.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and not c:IsCode(40320754) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的取对象处理：若为连锁对象检查则要求该卡在自己墓地、属于自己且通过filter筛选；若为发动时点检查则返回true表示可发动；随后提示选择，从自己墓地选1张符合条件的植物族怪兽作为效果对象，并登记本次连锁包含特殊召唤操作。
function c40320754.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40320754.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 给玩家弹出选择提示“请选择要特殊召唤的卡”（HINT_SELECTMSG与HINTMSG_SPSUMMON配合），用于后续Duel.SelectTarget的选卡界面文案。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的植物族怪兽中选出1张「毒根王」以外且满足filter的卡，作为本效果的对象并自动与当前连锁建立联系。
	local g=Duel.SelectTarget(tp,c40320754.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次连锁将进行特殊召唤，对象为所选怪兽g，数量为1，以便其他卡片能正确响应或限制。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段执行特殊召唤：取得之前选择的对象，确认它仍与效果相关且仍是植物族后，将其特殊召唤到场上。
function c40320754.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的第一张对象卡（即发动时选择的墓地植物族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将对象怪兽以表侧表示特殊召唤到玩家tp的场上，并保留召唤条件与苏生限制的检查（nocheck=false, nolimit=false）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
