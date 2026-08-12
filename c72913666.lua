--ゴーストリック・ワーウルフ
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，这张卡反转时，给与对方基本分场上盖放的卡数量×100的数值的伤害。「鬼计狼人」的这个效果1回合只能使用1次。
function c72913666.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c72913666.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72913666,0))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c72913666.postg)
	e2:SetOperation(c72913666.posop)
	c:RegisterEffect(e2)
	-- 这张卡反转时，给与对方基本分场上盖放的卡数量×100的数值的伤害。「鬼计狼人」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72913666,1))  --"LP伤害"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_FLIP)
	e3:SetCountLimit(1,72913666)
	e3:SetTarget(c72913666.damtg)
	e3:SetOperation(c72913666.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的名字带有「鬼计」的怪兽。
function c72913666.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的启用条件：自己场上不存在表侧表示的名字带有「鬼计」的怪兽。
function c72913666.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的名字带有「鬼计」的怪兽。
	return not Duel.IsExistingMatchingCard(c72913666.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的目标处理：检查自身是否能变成里侧表示且本回合未发动过该效果，注册已发动标记，并设置改变表示形式的操作信息。
function c72913666.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(72913666)==0 end
	c:RegisterFlagEffect(72913666,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将自身改变表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的运行空间：若自身仍存在于场上且呈表侧表示，则将其转为里侧守备表示。
function c72913666.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转伤害效果的目标处理：此效果为必发效果，直接返回true，计算场上盖放的卡数量，设置对方为目标玩家，设置伤害数值，并设置给与对方伤害的操作信息。
function c72913666.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上盖放的卡片数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置效果的目标玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为场上盖放的卡数量×100。
	Duel.SetTargetParam(ct*100)
	-- 设置操作信息：给与对方玩家场上盖放的卡数量×100的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,ct*100)
end
-- 反转伤害效果的运行空间：获取目标玩家，重新计算场上盖放的卡数量，并给与该玩家对应数值的效果伤害。
function c72913666.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算双方场上盖放的卡片数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 以效果原因给与目标玩家场上盖放的卡数量×100的伤害。
	Duel.Damage(p,ct*100,REASON_EFFECT)
end
