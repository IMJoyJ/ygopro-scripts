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
-- 怪兽过滤条件：由指定玩家特殊召唤、表侧表示未被无效、且攻击力在2000以上的效果怪兽
function c1005587.filter(c,tp)
	-- 返回是否属于由指定玩家特殊召唤、表侧表示未被无效、且攻击力在2000以上的效果怪兽
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- 效果发动准备：检查对方特殊召唤的怪兽中是否存在满足条件的怪兽，将其设为效果对象，并向系统注册破坏的操作信息
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 把当前特殊召唤的怪兽组设置为当前连锁的对象
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 向系统注册当前连锁的操作信息：效果分类为破坏，目标卡片为筛选出的怪兽组g，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤满足特殊召唤条件且与当前效果有联系的怪兽
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- 效果的执行：在符合条件的特殊召唤怪兽中，选择其中1只怪兽使其效果无效，并将其破坏
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 在提示框显示“请选择要破坏的卡”的系统提示
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
		-- 手动刷新场上卡片的无效状态
		Duel.AdjustInstantly()
		-- 使与该怪兽有关的连锁都无效化，若变里侧则重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 并破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
