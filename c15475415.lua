--エーリアン・ドッグ
-- 效果：
-- 自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。
function c15475415.initial_effect(c)
	-- 自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15475415,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15475415.spcon)
	e1:SetTarget(c15475415.sptg)
	e1:SetOperation(c15475415.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15475415,1))  --"放置「A指示物」"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c15475415.ctcon)
	e2:SetOperation(c15475415.ctop)
	c:RegisterEffect(e2)
end
c15475415.counter_add_list={0x100e}
c15475415.mentioned_counter={
	[0x100e]=true,
}
-- 发动条件：通常召唤成功的怪兽是自己场上的，且该怪兽是名字带有「外星」（卡组系列0xc）的怪兽。
function c15475415.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSetCard(0xc)
end
-- 发动时检测：自己的主要怪兽区有空位，且这张卡可以从手卡特殊召唤，才满足发动条件。
function c15475415.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区可用空格数是否大于0（是否有空位可以特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将特殊召唤这张卡自身1张，用于星尘龙等效果的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与该效果关联，则将这张卡从手卡以自身效果表侧表示特殊召唤到自己场上。
function c15475415.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以自身效果（SUMMON_VALUE_SELF）从手卡表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 发动条件：这张卡是以自身效果特殊召唤成功的（召唤方式为特殊召唤+自身效果）。
function c15475415.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果处理：检索对方场上可以放置A指示物的怪兽，若有则分2次各选择1只，各放置1个A指示物（共2个）。
function c15475415.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方怪兽区域中所有可以放置A指示物（0x100e）的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,2 do
		-- 向玩家提示「请选择表侧表示的卡」，用于选择要放置A指示物的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
