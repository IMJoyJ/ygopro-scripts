--リチュア・ビースト
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只4星以下的名字带有「遗式」的怪兽表侧守备表示特殊召唤。
function c36227804.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地存在的1只4星以下的名字带有「遗式」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36227804,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c36227804.target)
	e1:SetOperation(c36227804.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是4星以下、名字带有「遗式」的怪兽，且可以表侧守备表示特殊召唤。
function c36227804.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 对象检查与发动条件确认：若为连锁指定对象，则验证该对象是否为己方墓地的满足条件的「遗式」怪兽；发动时还需确认自己主要怪兽区有空位且墓地存在满足条件的对象。
function c36227804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36227804.filter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区域必须存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查自己墓地是否存在至少1只满足筛选条件且能成为本效果对象的「遗式」怪兽。
		Duel.IsExistingTarget(c36227804.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「遗式」怪兽，并将其设置为效果的对象。
	local g=Duel.SelectTarget(tp,c36227804.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，表明本效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，获取之前选择的对象；若对象仍与本效果关联，则将其以表侧守备表示特殊召唤。
function c36227804.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果当前连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
