--大狼雷鳴
-- 效果：
-- 这张卡的效果发动的回合，自己不能进行战斗阶段。
-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。对方场上的表侧表示怪兽全部破坏。
function c13683298.initial_effect(c)
	-- 创建一个诱发选发效果，对应卡片效果①的发动条件
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
-- 效果发动的条件：这张卡从墓地特殊召唤成功
function c13683298.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果发动的费用：支付1点战斗阶段次数
function c13683298.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在战斗阶段前未进行过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 设置一个场上的永续效果，使玩家不能进入战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判断怪兽是否为表侧表示
function c13683298.filter(c)
	return c:IsFaceup()
end
-- 效果发动的目标选择函数
function c13683298.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13683298.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(c13683298.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动的处理函数
function c13683298.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(c13683298.filter,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上所有表侧表示怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
