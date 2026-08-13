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
-- 判定条件：受到战斗伤害的玩家（ep）是自己（tp），即只有自己受到战斗伤害时才满足发动条件。
function c13313278.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果发动时的合法性检查：确认自己场上有可用的主要怪兽区域，且这张卡能够以效果进行特殊召唤（满足召唤条件和苏生限制）。
function c13313278.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件之一，确认自己的主要怪兽区域存在空格，可供这张卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本连锁的操作信息：本次效果包含特殊召唤，对象确定为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 登记本连锁的操作信息：本次效果包含回复LP，回复方为自己，预计回复数值为受到的战斗伤害的数值ev；因回复对象在效果处理时确定，故对象为nil。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理时：若这张卡仍与效果保持关联，则将其表侧表示特殊召唤到自己的主要怪兽区域；若特殊召唤成功，则回复自己等于这次受到的战斗伤害数值的LP。
function c13313278.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否仍与本效果关联（没有因离场等原因失效），并执行特殊召唤；只有特殊召唤成功（返回非0）时才继续后面的回复处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 以效果原因使自己回复ev点LP，ev为这次受到的战斗伤害的数值。
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
