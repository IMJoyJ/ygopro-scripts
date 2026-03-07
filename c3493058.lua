--サイコロン
-- 效果：
-- ①：掷1次骰子，出现的数目的效果适用。
-- ●2·3·4：选场上1张魔法·陷阱卡破坏。
-- ●5：选场上2张魔法·陷阱卡破坏。
-- ●1·6：自己受到1000伤害。
function c3493058.initial_effect(c)
	-- 效果原文：①：掷1次骰子，出现的数目的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c3493058.target)
	e1:SetOperation(c3493058.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：●2·3·4：选场上1张魔法·陷阱卡破坏。
function c3493058.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果原文：●5：选场上2张魔法·陷阱卡破坏。
function c3493058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果原文：●1·6：自己受到1000伤害。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 创建效果对象并设置其类型为发动效果，触发条件为自由连锁，设置目标函数和发动函数
function c3493058.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个过滤函数，用于筛选魔法卡或陷阱卡
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==6 then
		-- 设置操作信息，表示该效果会进行一次骰子投掷
		Duel.Damage(tp,1000,REASON_EFFECT)
	elseif dc==5 then
		-- 投掷一次骰子，结果保存在dc变量中
		local g=Duel.GetMatchingGroup(c3493058.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		if g:GetCount()<2 then return end
		-- 对自身造成1000点伤害
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,2,2,nil)
		-- 获取场上满足条件的魔法·陷阱卡组
		Duel.HintSelection(dg)
		-- 提示选择要破坏的卡
		Duel.Destroy(dg,REASON_EFFECT)
	elseif dc>=2 and dc<=4 then
		-- 显示选中的卡被选为对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 破坏指定数量的卡
		local g=Duel.SelectMatchingCard(tp,c3493058.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		-- 提示选择要破坏的卡
		Duel.HintSelection(g)
		-- 显示选中的卡被选为对象
		Duel.Destroy(g,REASON_EFFECT)
	end
end
