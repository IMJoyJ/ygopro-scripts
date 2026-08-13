--ヴァイロン・ハプト
-- 效果：
-- 1回合1次，可以选择当作装备卡使用在自己场上存在的1张名字带有「大日」的怪兽卡表侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
function c168917.initial_effect(c)
	-- 1回合1次，可以选择当作装备卡使用在自己场上存在的1张名字带有「大日」的怪兽卡表侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(168917,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c168917.sptg)
	e1:SetOperation(c168917.spop)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的对象：表侧表示、作为装备卡装备在怪兽身上、卡名带有「大日」字段，且能够以表侧守备表示被特殊召唤。
function c168917.filter(c,e,tp)
	return c:IsFaceup() and c:GetEquipTarget() and c:IsSetCard(0x30) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标选择与发动合法性检查：若chkc是卡片，则校验其是否为自己魔陷区的表侧装备卡且满足筛选条件；若chk==0，则检查是否满足发动条件（有空格且存在符合条件的对象）。
function c168917.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c168917.filter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区有空余位置，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己魔陷区存在1张满足筛选条件且能成为效果对象的装备卡（当作装备卡使用的大日怪兽）。
		and Duel.IsExistingTarget(c168917.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己魔陷区选择1张满足条件的卡作为对象，并将该卡登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c168917.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁会进行1只怪兽的特殊召唤，供其他卡牌根据此信息发动或响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取出对象并执行特殊召唤；若特殊召唤成功，则给该怪兽附加离场时改为从游戏中除外的效果。
function c168917.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡与效果仍有联系后，以表侧守备表示将其特殊召唤到自己场上；若特殊召唤成功（返回值不等于0），则继续执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
