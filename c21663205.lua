--墓守の神職
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以自己墓地1只4星「守墓」怪兽为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。这个效果不受「王家长眠之谷」的效果影响。
function c21663205.initial_effect(c)
	-- “这个卡名的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合，以自己墓地1只4星「守墓」怪兽为对象才能发动。那只怪兽表侧攻击表示或者里侧守备表示特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21663205,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21663205)
	e1:SetTarget(c21663205.sptg)
	e1:SetOperation(c21663205.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- “这个效果不受「王家长眠之谷」的效果影响。”
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_NECRO_VALLEY_IM)
	c:RegisterEffect(e4)
end
-- 检查卡片是否为等级4的「守墓」怪兽，且能够被当前效果特殊召唤（表侧攻击表示或里侧守备表示），用于筛选自己墓地中的可特殊召唤对象。
function c21663205.filter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(0x2e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 发动条件与取对象处理：验证指定对象必须是我方墓地的4星「守墓」怪兽；在发动检查时确认场上存在可用的主怪兽区空格，并且墓地存在满足条件的对象。
function c21663205.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21663205.filter(chkc,e,tp) end
	-- 检查我方主要怪兽区是否有空位，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方墓地是否存在至少1只满足筛选条件的4星「守墓」怪兽，且该怪兽能够成为效果对象。
		and Duel.IsExistingTarget(c21663205.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示，用于接下来的选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方墓地选择1只4星「守墓」怪兽作为效果对象，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c21663205.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁操作的特殊召唤信息（目标组为所选的卡，数量为1），供其他卡检测或响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象卡，若对象仍与效果关联，则以表侧攻击表示或里侧守备表示将其特殊召唤；若以里侧守备表示特殊召唤成功，则向对方确认该怪兽。
function c21663205.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所选择的第一张目标卡（即之前选定的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡仍与效果关联，然后以表侧攻击表示或里侧守备表示将其特殊召唤到我方场上；若特殊召唤成功则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFacedown() then
		-- 若对象是以里侧守备表示被特殊召唤的，则向对方玩家展示该里侧守备表示的怪兽卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
