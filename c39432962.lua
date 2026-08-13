--ドドドウィッチ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把「怒怒怒魔女」以外的1只「怒怒怒」怪兽表侧攻击表示或者里侧守备表示特殊召唤。
function c39432962.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把「怒怒怒魔女」以外的1只「怒怒怒」怪兽表侧攻击表示或者里侧守备表示特殊召唤。
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
-- 判定手牌中的怪兽是否为「怒怒怒」系列且不是「怒怒怒魔女」，并满足以表侧攻击表示或里侧守备表示被特殊召唤的条件。
function c39432962.filter(c,e,tp)
	return c:IsSetCard(0x82) and not c:IsCode(39432962) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 效果的发动条件：自己主要怪兽区有空位，且手牌中存在符合条件的「怒怒怒」怪兽。
function c39432962.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在1只满足条件的「怒怒怒」怪兽。
		and Duel.IsExistingMatchingCard(c39432962.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果将进行特殊召唤，处理对象为手牌中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时，若自己场上仍有空格，则从手牌选择1只符合条件的「怒怒怒」怪兽，以表侧攻击或里侧守备表示特殊召唤；若为里侧守备表示则向对方确认。
function c39432962.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区，则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1只满足条件的「怒怒怒」怪兽。
	local g=Duel.SelectMatchingCard(tp,c39432962.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示或里侧守备表示特殊召唤；若特殊召唤成功且为里侧守备表示，则继续向对方确认。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 将里侧守备表示特殊召唤的怪兽向对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
