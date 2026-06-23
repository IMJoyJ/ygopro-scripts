--煉獄の落とし穴
-- 效果：
-- ①：对方把攻击力2000以上的怪兽特殊召唤时才能发动。选那1只攻击力2000以上的怪兽，把效果无效并破坏。
function c1005587.initial_effect(c)
	-- 创建效果，设置效果类别为破坏，类型为激活，触发条件为特殊召唤成功，目标选择函数为c1005587.target，操作函数为c1005587.activate，并将该效果注册到卡片c上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c1005587.target)
	e1:SetOperation(c1005587.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数c1005587.filter，用于筛选攻击力大于等于2000且由对方玩家特殊召唤的怪兽。
function c1005587.filter(c,tp)
	-- 返回aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)，即判断卡片是否为可无效效果怪兽，攻击力是否大于等于2000，以及召唤者是否为对方玩家。
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- 定义目标选择函数c1005587.target，在chk=0时检查是否有满足c1005587.filter条件的卡片存在，设置目标卡，并使用Duel.SetOperationInfo设置操作信息。
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 将当前正在处理的连锁的对象设置为eg（效果的目标）
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 设置当前处理的连锁的操作信息：类别为破坏(CATEGORY_DESTROY)，目标卡组为g，数量为1，目标玩家为0，参数为0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义过滤函数c1005587.filter2，用于筛选满足c1005587.filter条件且与当前效果e有联系的怪兽。
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- 定义激活函数c1005587.activate，筛选满足条件的卡片，获取第一张卡片，如果存在多于一张则提示选择，判断目标卡是否可以被效果无效化，创建并注册效果以禁用该卡，刷新场上状态，使相关连锁无效化，并破坏目标卡。
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 向玩家tp发送提示信息，提示其选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc:IsCanBeDisabledByEffect(e) then
		-- 创建单次效果，类型为效果无效(EFFECT_DISABLE)，代码为EFFECT_DISABLE，重置条件为事件触发+标准重置(RESET_EVENT+RESETS_STANDARD)，并将其注册到目标卡tc上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 手动刷新场上受到影响的卡的无效状态
		Duel.AdjustInstantly()
		-- 使和卡片tc有关的连锁都无效化，发生reset事件则重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 以效果原因(REASON_EFFECT)破坏目标卡tc。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
