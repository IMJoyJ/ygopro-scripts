--エクストラ・ヴェーラー
-- 效果：
-- 对方把怪兽特殊召唤时，可以从手卡把这张卡特殊召唤。这个效果特殊召唤的回合，对方的卡的效果发生的对自己的效果伤害由对方代受。
function c32391566.initial_effect(c)
	-- 对方把怪兽特殊召唤时，可以从手卡把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32391566,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32391566.spcon)
	e1:SetTarget(c32391566.sptg)
	e1:SetOperation(c32391566.spop)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否为对方召唤
function c32391566.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果发动的条件：对方有怪兽特殊召唤成功
function c32391566.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32391566.cfilter,1,nil,1-tp)
end
-- 准备阶段检查是否可以特殊召唤
function c32391566.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤成功后，使对方受到的对自己造成的伤害由对方承担
function c32391566.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡能被特殊召唤且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 创建一个反射伤害的效果，使对方受到的对自己造成的伤害由对方承担
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_REFLECT_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c32391566.val)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将反射伤害效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断伤害是否由效果造成
function c32391566.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
