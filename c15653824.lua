--スカル・ナイト
-- 效果：
-- 用这张卡做祭品召唤恶魔族怪兽的场合，从卡组特殊召唤1张「骷髅骑士」上场。之后卡组洗切。
function c15653824.initial_effect(c)
	-- 对应效果原文：“用这张卡做祭品召唤恶魔族怪兽的场合，从卡组特殊召唤1张「骷髅骑士」上场。之后卡组洗切。”该段代码将该效果注册为这张卡的诱发效果，并绑定条件、发动时处理和效果处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15653824,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c15653824.spcon)
	e1:SetTarget(c15653824.sptg)
	e1:SetOperation(c15653824.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：这张卡必须是因为召唤（REASON_SUMMON）而作为祭品被解放，并且导致解放的怪兽是表侧表示且种族为恶魔族。
function c15653824.spcon(e,tp,eg,ep,ev,re,r,rp)
	if r~=REASON_SUMMON then return false end
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsFaceup() and rc:IsRace(RACE_FIEND)
end
-- 效果发动时的目标处理：该效果不取对象，直接返回true允许发动，同时登记将从卡组特殊召唤怪兽的操作信息。
function c15653824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息记录为“从卡组特殊召唤1只怪兽”，便于其他卡片或效果进行连锁判定和时点响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤的过滤条件：从卡组选择卡名相同的「骷髅骑士」，且该卡能够被当前效果以正面表示特殊召唤。
function c15653824.spfilter(c,e,tp)
	return c:IsCode(15653824) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：确认主怪兽区有空位后，提示玩家选择要特殊召唤的卡，从卡组检索符合条件的「骷髅骑士」并将其特殊召唤到己方场上。
function c15653824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否有空位；如果没有空位，则效果处理直接中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，用于后续从卡组挑选卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中获取第一张符合c15653824.spfilter过滤条件的「骷髅骑士」。
	local tc=Duel.GetFirstMatchingCard(c15653824.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选中的「骷髅骑士」以表侧攻击表示特殊召唤到己方场上，不检查召唤条件且不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
