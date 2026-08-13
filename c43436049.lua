--ジャンク・ブレイカー
-- 效果：
-- ①：这张卡召唤成功的回合的自己主要阶段，把这张卡解放才能发动。场上的全部表侧表示怪兽的效果直到回合结束时无效。
function c43436049.initial_effect(c)
	-- 这张卡召唤成功的回合的
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c43436049.sumsuc)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功的回合的自己主要阶段，把这张卡解放才能发动。场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43436049,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c43436049.condition)
	e2:SetCost(c43436049.cost)
	e2:SetTarget(c43436049.target)
	e2:SetOperation(c43436049.operation)
	c:RegisterEffect(e2)
end
-- 召唤成功时给自身设置标记，用于记录本回合召唤成功；该标记在回合结束或离场等场合重置。
function c43436049.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(43436049,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 发动条件：自身拥有召唤成功标记，即本回合召唤成功过。
function c43436049.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(43436049)>0
end
-- 代价：将自身解放。先确认自身可解放，然后执行解放作为发动代价。
function c43436049.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动代价（REASON_COST，不检查是否受效果影响）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标处理：确认场上存在至少1只可无效的表侧表示效果怪兽（排除自身），并获取这些怪兽的集合，设置操作信息以宣告将无效它们。
function c43436049.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：场上存在除自身以外至少1只可被无效的表侧表示效果怪兽（否则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除自身以外所有可无效的表侧表示效果怪兽，作为将要被无效的对象集合。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息：将上述怪兽集合标记为本效果要无效的对象（CATEGORY_DISABLE），供连锁时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理：将场上全部表侧表示的效果怪兽（此时自身已解放）的怪兽效果无效，直到回合结束时。
function c43436049.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取场上全部表侧表示效果怪兽（无需排除自身，因为自身已不在场上）。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部表侧表示怪兽的效果直到回合结束时无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 场上的全部表侧表示怪兽的效果直到回合结束时无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
