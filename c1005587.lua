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
-- 筛选符合条件的怪兽：表侧表示、未被效果无效化、是效果怪兽且攻击力2000以上且是对方特殊召唤的
function c1005587.filter(c,tp)
	-- 返回筛选条件：满足怪兽过滤器、攻击力2000以上、是对方召唤的
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- 效果发动时的目标选择函数
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 将连锁中特殊召唤成功的怪兽设为处理对象
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 设置操作信息：破坏效果，目标为符合条件的怪兽组，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 用于激活阶段筛选目标的过滤函数
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- 效果发动时的处理函数
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc:IsCanBeDisabledByEffect(e) then
		-- 创建一个使目标怪兽效果无效的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 立即刷新场上卡牌的无效状态
		Duel.AdjustInstantly()
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
