--BK ベイル
-- 效果：
-- 自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
function c13313278.initial_effect(c)
	-- 自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13313278,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c13313278.spcon)
	e1:SetTarget(c13313278.sptg)
	e1:SetOperation(c13313278.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：造成战斗伤害的玩家是自己
function c13313278.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果处理目标设定：检查是否满足特殊召唤和回复LP的条件
function c13313278.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：自己基本分回复受到的伤害数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理执行：执行特殊召唤并回复LP
function c13313278.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡存在于场上且满足特殊召唤条件，执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使自己基本分回复受到的战斗伤害数值
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
