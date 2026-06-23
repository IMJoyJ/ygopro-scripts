--ドドドウィッチ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把「怒怒怒魔女」以外的1只「怒怒怒」怪兽表侧攻击表示或者里侧守备表示特殊召唤。
function c39432962.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39432962,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c39432962.sptg)
	e1:SetOperation(c39432962.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中满足条件的「怒怒怒」怪兽（不包括自身）
function c39432962.filter(c,e,tp)
	return c:IsSetCard(0x82) and not c:IsCode(39432962) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c39432962.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的「怒怒怒」怪兽
		and Duel.IsExistingMatchingCard(c39432962.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c39432962.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的「怒怒怒」怪兽
	local g=Duel.SelectMatchingCard(tp,c39432962.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧攻击或里侧守备形式特殊召唤
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 如果特殊召唤的怪兽是里侧表示，则向对方确认该怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
