--レッド・ワイバーン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只在同调召唤的这张卡表侧表示存在才有1次，自己·对方回合，持有比这张卡高的攻击力的怪兽在场上存在的场合才能发动。场上1只攻击力最高的怪兽破坏。
function c76547525.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只在同调召唤的这张卡表侧表示存在才有1次，自己·对方回合，持有比这张卡高的攻击力的怪兽在场上存在的场合才能发动。场上1只攻击力最高的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76547525,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c76547525.descon)
	e1:SetTarget(c76547525.destg)
	e1:SetOperation(c76547525.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且攻击力比指定数值高的怪兽
function c76547525.cfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk
end
-- 发动条件：此卡是同调召唤上场，且场上存在比此卡攻击力高的怪兽
function c76547525.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查双方场上是否存在至少1只攻击力比此卡高的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c76547525.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
-- 过滤条件：场上表侧表示的怪兽
function c76547525.desfilter(c)
	return c:IsFaceup()
end
-- 发动目标：检查场上是否存在表侧表示怪兽，并获取攻击力最高的怪兽组，设置破坏操作信息
function c76547525.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76547525.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c76547525.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置操作信息：破坏场上1张攻击力最高的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 效果处理：获取场上攻击力最高的怪兽，若有多个则由发动效果的玩家选择1只破坏，否则直接破坏那1只
function c76547525.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c76547525.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 向双方玩家展示所选择的卡片
			Duel.HintSelection(sg)
			-- 因效果破坏选中的那1只怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 否则（攻击力最高的怪兽只有1只时），直接因效果破坏该怪兽
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
