--煉獄の落とし穴
-- 效果：
-- ①：对方把攻击力2000以上的怪兽特殊召唤时才能发动。选那1只攻击力2000以上的怪兽，把效果无效并破坏。
function c1005587.initial_effect(c)
	-- ①：对方把攻击力2000以上的怪兽特殊召唤时才能发动。选那1只攻击力2000以上的怪兽，把效果无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c1005587.target)
	e1:SetOperation(c1005587.activate)
	c:RegisterEffect(e1)
end
-- 过滤被对方特殊召唤且攻击力在2000以上的可无效怪兽
function c1005587.filter(c,tp)
	-- 检查怪兽是否符合特召方、攻击力与可无效性限制
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- 效果发动时的目标选择与检查
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 设置被召唤的怪兽组为当前效果的目标
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 声明无效并破坏怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤出与当前效果相关联且符合条件的破坏怪兽
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- 效果发动的实际操作：无效怪兽效果并将其破坏
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 提示选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc:IsCanBeDisabledByEffect(e) then
		-- 从多只同时特召的怪兽中选出1只作为无效并破坏的对象
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 即时刷新场上卡片状态
		Duel.AdjustInstantly()
		-- 阻断并重置被选怪兽的相关连锁状态
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 将选中的对方怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
