--大狼雷鳴
-- 效果：
-- 这张卡的效果发动的回合，自己不能进行战斗阶段。
-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示怪兽全部破坏。
function c13683298.initial_effect(c)
	-- 这张卡的效果发动的回合，自己不能进行战斗阶段。①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c13683298.condition)
	e1:SetCost(c13683298.cost)
	e1:SetTarget(c13683298.target)
	e1:SetOperation(c13683298.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡在被特殊召唤成功之前是否位于墓地，即是否满足“从墓地特殊召唤成功”的诱发条件。
function c13683298.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 作为发动代价：若本回合尚未进入过战斗阶段，则给发动玩家施加本回合不能进入战斗阶段的誓约效果。
function c13683298.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost的合法性检查：确认发动玩家本回合没有进入过战斗阶段。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡的效果发动的回合，自己不能进行战斗阶段。①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个禁止进入战斗阶段的永续效果注册给玩家tp，使其本回合剩余时间内无法进入战斗阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：选出表侧表示的怪兽，用于确定为破坏对象。
function c13683298.filter(c)
	return c:IsFaceup()
end
-- target处理：效果发动时校验对方场上有表侧表示怪兽，并将对方场上全部表侧表示怪兽设为将被破坏的对象。
function c13683298.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13683298.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上全部表侧表示怪兽，作为本次效果预定破坏的卡片组。
	local g=Duel.GetMatchingGroup(c13683298.filter,tp,0,LOCATION_MZONE,nil)
	-- 向系统提交破坏信息：将上述怪兽组标记为本次连锁要破坏的对象，并指定数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- operation处理：效果结算时再次取得对方场上全部表侧表示怪兽，并将它们全部破坏。
function c13683298.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新选取对方场上目前存在表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c13683298.filter,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
