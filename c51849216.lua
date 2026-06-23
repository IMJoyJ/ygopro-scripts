--ドラグニティ・ヴォイド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「龙骑兵团」同调怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并除外。自己场上有10星「龙骑兵团」怪兽存在的场合，可以再让自己场上1只「龙骑兵团」怪兽的攻击力上升表侧除外中的卡数量×100。
function c51849216.initial_effect(c)
	-- 效果设置：使该卡在对方发动魔法·陷阱卡时可以无效并除外，且满足条件时可让场上怪兽攻击力上升
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,51849216+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c51849216.condition)
	-- 设置效果目标处理函数为aux.nbtg，用于处理连锁无效和除外操作
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c51849216.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上的表侧表示的「龙骑兵团」同调怪兽
function c51849216.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsType(TYPE_SYNCHRO)
end
-- 条件判断：对方发动魔法·陷阱卡且该连锁可被无效，并且自己场上存在「龙骑兵团」同调怪兽
function c51849216.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：对方发动魔法·陷阱卡且该连锁可被无效
	return ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 条件判断：自己场上存在「龙骑兵团」同调怪兽
		and Duel.IsExistingMatchingCard(c51849216.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选场上的表侧表示的「龙骑兵团」怪兽
function c51849216.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 过滤函数：筛选场上的表侧表示的10星「龙骑兵团」怪兽
function c51849216.cfilter(c)
	return c51849216.atkfilter(c) and c:IsLevel(10)
end
-- 效果发动处理：无效对方魔法·陷阱卡的发动并除外，若满足条件则可让场上怪兽攻击力上升
function c51849216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效化对方发动的效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 将对方发动的魔法·陷阱卡除外
		and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0 and eg:GetFirst():IsLocation(LOCATION_REMOVED) then
		-- 统计表侧除外中的卡数量
		local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		-- 判断自己场上是否存在10星「龙骑兵团」怪兽
		if Duel.IsExistingMatchingCard(c51849216.cfilter,tp,LOCATION_MZONE,0,1,nil) and ct>0
			-- 询问玩家是否选择让场上怪兽攻击力上升
			and Duel.SelectYesNo(tp,aux.Stringid(51849216,0)) then  --"是否选怪兽上升攻击力？"
			-- 中断当前效果处理，使后续效果不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择表侧表示的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 选择场上一只表侧表示的「龙骑兵团」怪兽
			local g=Duel.SelectMatchingCard(tp,c51849216.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 显示所选怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			-- 给选中的怪兽赋予攻击力上升效果，数值为除外卡数量×100
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ct*100)
			tc:RegisterEffect(e1)
		end
	end
end
