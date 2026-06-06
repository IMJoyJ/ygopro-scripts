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
-- 过滤函数：筛选特殊召唤成功的符合条件的怪兽，条件为：表侧表示且未被无效的效果怪兽、攻击力在2000以上、且由指定玩家特殊召唤
function c1005587.filter(c,tp)
	-- 条件判断：卡片是表侧表示且未被无效的效果怪兽，且攻击力在2000以上，且特殊召唤该怪兽的玩家是指定玩家
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2000) and c:IsSummonPlayer(tp)
end
-- ①效果的 target 函数：判断是否有符合触发条件的特殊召唤成功的怪兽，并设定效果的操作信息与潜在处理卡片
function c1005587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1005587.filter,1,nil,1-tp) end
	-- 设置卡片联系：将特殊召唤成功的怪兽组与当前效果建立联系
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c1005587.filter,nil,1-tp)
	-- 设置操作信息：设置效果处理包含破坏，预计破坏的怪兽数量为1只
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：在效果处理时进行二次筛选，确保特殊召唤的怪兽仍符合条件且与该效果存在联系
function c1005587.filter2(c,e,tp)
	return c1005587.filter(c,tp) and c:IsRelateToEffect(e)
end
-- ①效果的 operation 函数（效果处理）：如果有多只怪兽同时召唤时触发则选择其中1只，然后将其效果无效并破坏
function c1005587.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c1005587.filter2,nil,e,1-tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 提示信息：提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	if tc:IsCanBeDisabledByEffect(e) then
		-- 把效果无效（使怪兽自身效果无效）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 刷新状态：手动立即刷新场上怪兽的状态，使其无效状态即时生效
		Duel.AdjustInstantly()
		-- 无效相关连锁：使和该怪兽有关的连锁中已发动的效果也无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 破坏怪兽：通过效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
