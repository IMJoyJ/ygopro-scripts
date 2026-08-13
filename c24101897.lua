--ゴーストリックの猫娘
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，只要场上有这张卡以外的名字带有「鬼计」的怪兽存在，4星以上的怪兽召唤·特殊召唤成功时，那些怪兽变成里侧守备表示。
function c24101897.initial_effect(c)
	-- 对应效果原文：自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c24101897.sumcon)
	c:RegisterEffect(e1)
	-- 对应效果原文：这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24101897,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c24101897.postg)
	e2:SetOperation(c24101897.posop)
	c:RegisterEffect(e2)
	-- 对应效果原文：此外，只要场上有这张卡以外的名字带有「鬼计」的怪兽存在，4星以上的怪兽召唤·特殊召唤成功时，那些怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24101897,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c24101897.condition)
	e3:SetTarget(c24101897.target)
	e3:SetOperation(c24101897.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为表侧表示且拥有「鬼计」字段（0x8d）。
function c24101897.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制条件：当自己场上不存在满足sfilter的表侧「鬼计」怪兽时，禁止这张卡召唤（以此实现“有鬼计怪兽存在才能表侧表示召唤”）。
function c24101897.sumcon(e)
	-- 检查自己场上不存在表侧「鬼计」怪兽，若不存在则条件成立，触发禁止召唤。
	return not Duel.IsExistingMatchingCard(c24101897.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 起动效果的目标检查与发动准备：自身可以变为里侧守备且本回合尚未用过此效果才可发动；发动时注册一回合一次的标志，并设置将自身变为里侧守备的操作信息。
function c24101897.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(24101897)==0 end
	c:RegisterFlagEffect(24101897,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：登记改变表示形式的效果，指定对象为这张卡自身，数量1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理：若这张卡仍与效果关联且处于表侧表示，则将其变为里侧守备表示。
function c24101897.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡从表侧表示变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 诱发效果的条件：自己场上存在这张卡以外的表侧表示「鬼计」怪兽。
function c24101897.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否至少存在1张排除自身以外的表侧「鬼计」怪兽。
	return Duel.IsExistingMatchingCard(c24101897.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：筛选出表侧表示、4星以上、可以变为里侧守备、且（若传入e）仍与本次效果关联的怪兽。
function c24101897.filter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(4) and c:IsCanTurnSet() and (not e or c:IsRelateToEffect(e))
end
-- 诱发效果的发动条件与目标设定：若刚召唤/特殊召唤成功的怪兽组eg中存在满足filter的怪兽则可发动；发动时将eg设为关联对象，再筛出实际要变里侧的g，并登记操作信息。
function c24101897.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c24101897.filter,1,nil) end
	-- 将召唤/特殊召唤成功的这组怪兽设置为当前连锁的关联对象（广义对象），用于后续判断是否与效果关联。
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c24101897.filter,nil)
	-- 设置操作信息：登记将筛选出的g中的怪兽变为里侧守备，数量为g的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：若自己场上仍存在其他表侧「鬼计」怪兽，则将召唤/特殊召唤成功且满足条件的怪兽全部变为里侧守备表示。
function c24101897.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认条件：若自己场上已不存在其他表侧「鬼计」怪兽，则不处理后续效果。
	if not Duel.IsExistingMatchingCard(c24101897.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	local g=eg:Filter(c24101897.filter,nil,e)
	-- 将满足条件的召唤/特殊召唤成功的怪兽全部变为里侧守备表示。
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
