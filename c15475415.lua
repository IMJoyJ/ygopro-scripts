--エーリアン・ドッグ
-- 效果：
-- 自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。
function c15475415.initial_effect(c)
	-- 创建一个诱发选发效果，当自己对名字带有「外星」的怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
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
	-- 创建一个诱发必发效果，这个效果特殊召唤成功时，给对方场上表侧表示存在的怪兽放置2个A指示物。
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
-- 效果条件：确认是自己召唤成功且被召唤的怪兽名字带有「外星」。
function c15475415.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSetCard(0xc)
end
-- 效果目标：检查是否有足够的怪兽区域可以特殊召唤此卡。
function c15475415.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域可以特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置此效果的处理信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上。
function c15475415.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到召唤者的场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 效果条件：确认此卡是通过特殊召唤方式出场的。
function c15475415.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果处理：选择对方场上表侧表示存在的怪兽各放置1个A指示物，共放置2个。
function c15475415.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以放置指示物的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x100e,1)
	if g:GetCount()==0 then return end
	for i=1,2 do
		-- 提示选择一个表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
