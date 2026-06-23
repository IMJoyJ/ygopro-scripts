--スカル・ナイト
-- 效果：
-- 用这张卡做祭品召唤恶魔族怪兽的场合，从卡组特殊召唤1张「骷髅骑士」上场。之后卡组洗切。
function c15653824.initial_effect(c)
	-- 诱发必发效果，当这张卡作为召唤的素材时发动
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
-- 效果发动时的条件判断：必须是因召唤而成为素材，并且作为素材的怪兽是表侧表示的恶魔族
function c15653824.spcon(e,tp,eg,ep,ev,re,r,rp)
	if r~=REASON_SUMMON then return false end
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsFaceup() and rc:IsRace(RACE_FIEND)
end
-- 效果的处理目标设定：准备从卡组特殊召唤1张骷髅骑士
function c15653824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表明将要从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 用于筛选卡组中符合条件的骷髅骑士卡片
function c15653824.spfilter(c,e,tp)
	return c:IsCode(15653824) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：检查场上是否有空位，提示选择并特殊召唤骷髅骑士
function c15653824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位，如果没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中检索满足条件的骷髅骑士卡片
	local tc=Duel.GetFirstMatchingCard(c15653824.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的骷髅骑士特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
