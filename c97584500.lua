--ゴーストリック・マミー
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，只要这张卡在场上表侧表示存在，自己在通常召唤外加上只有1次可以把1只名字带有「鬼计」的怪兽召唤。只要这张卡在场上表侧表示存在，自己不能把暗属性以外的怪兽特殊召唤。
function c97584500.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c97584500.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97584500,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c97584500.postg)
	e2:SetOperation(c97584500.posop)
	c:RegisterEffect(e2)
	-- 此外，只要这张卡在场上表侧表示存在，自己在通常召唤外加上只有1次可以把1只名字带有「鬼计」的怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97584500,1))  --"使用「鬼计木乃伊」的效果召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤效果的目标为名字带有「鬼计」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8d))
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，自己不能把暗属性以外的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(c97584500.splimit)
	c:RegisterEffect(e4)
end
-- 限制不能特殊召唤暗属性以外的怪兽
function c97584500.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_DARK
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c97584500.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制条件：自己场上没有表侧表示的「鬼计」怪兽时不能召唤
function c97584500.sumcon(e)
	-- 检查自己场上是否存在表侧表示的「鬼计」怪兽，若不存在则返回true（使不能召唤的效果生效）
	return not Duel.IsExistingMatchingCard(c97584500.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的靶向判定：检查自身是否能转为里侧守备表示且本回合未发动过，发动时注册一回合一次的标记并设置操作信息
function c97584500.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(97584500)==0 end
	c:RegisterFlagEffect(97584500,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息为将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的实际处理：若自身仍在场上且表侧表示，则将其转为里侧守备表示
function c97584500.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身转为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
