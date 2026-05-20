--子型ペンギン
-- 效果：
-- 反转过的这张卡被送去墓地时，从自己墓地选择「子型企鹅」以外的1只名字带有「企鹅」的怪兽表侧攻击表示或者里侧守备表示特殊召唤。
function c76442347.initial_effect(c)
	-- 反转过的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c76442347.flipop)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地时，从自己墓地选择「子型企鹅」以外的1只名字带有「企鹅」的怪兽表侧攻击表示或者里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76442347,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c76442347.spcon)
	e2:SetTarget(c76442347.sptg)
	e2:SetOperation(c76442347.spop)
	c:RegisterEffect(e2)
end
-- 反转时，给自身注册一个标记（Flag），用于记录该卡曾被反转过
function c76442347.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(76442347,RESET_EVENT+0x57a0000,0,0)
end
-- 检查自身是否带有反转过的标记
function c76442347.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(76442347)~=0
end
-- 过滤墓地中「子型企鹅」以外的名字带有「企鹅」且可以表侧攻击表示或里侧守备表示特殊召唤的怪兽
function c76442347.filter(c,e,tp)
	return c:IsSetCard(0x5a) and not c:IsCode(76442347) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤效果的发动准备：选择墓地中1只符合条件的「企鹅」怪兽作为对象，并设置特殊召唤的操作信息
function c76442347.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76442347.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「企鹅」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c76442347.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行：将选择的对象怪兽以表侧攻击表示或里侧守备表示特殊召唤，若里侧表示特殊召唤则向对方确认该卡
function c76442347.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽存在且仍符合效果，则将其以表侧攻击表示或里侧守备表示特殊召唤到自己场上
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFacedown() then
		-- 如果该怪兽是以里侧守备表示特殊召唤的，则向对方玩家展示并确认该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
