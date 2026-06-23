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
-- 特殊召唤怪兽的过滤条件函数：对方特殊召唤的、攻击力2000以上且可以被无效其效果的怪兽
function c1005587.filter(c,tp)
	-- 检查怪兽是否能被无效效果、攻击力是否在2000以上、以及特殊召唤该怪兽的玩家是否为对方玩家
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- 发动时目标（Target）处理：在发动时点检查对方特殊召唤的怪兽中是否存在攻击力2000以上的怪兽，将其记录并设定效果分类信息
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 将当前同时特殊召唤的怪兽组记录为当前效果可能处理的目标卡片
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 设置效果处理信息为破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 检测已被本卡建立联系且依然满足过滤条件的怪兽
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- 效果的处理（Operation）函数：在特殊召唤的攻击力2000以上怪兽中选1只，无效其效果并将其破坏
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 若有多个满足条件的怪兽同时特殊召唤，给玩家发送选择破坏卡的系统提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc:IsCanBeDisabledByEffect(e) then
		-- 把效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 手动刷新场上卡片的无效状态以使无效效果立即生效
		Duel.AdjustInstantly()
		-- 无效目标怪兽相关的连锁效果
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 将目标怪兽破坏并送去墓地
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
