--リンク・パーティー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：场上的连接怪兽的原本属性种类数量对应的以下适用。
-- ●1种类：自己场上的连接怪兽的攻击力上升500。
-- ●2种类：对方场上的连接怪兽的攻击力下降1000。
-- ●3种类：自己回复1500基本分。
-- ●4种类：给与对方2000伤害。
-- ●5种类：自己从卡组把1只攻击力2500以上的怪兽特殊召唤。
-- ●6种类：对方场上的攻击力3000以下的怪兽全部破坏。
function c68957925.initial_effect(c)
	-- ①：场上的连接怪兽的原本属性种类数量对应的以下适用。●1种类：自己场上的连接怪兽的攻击力上升500。●2种类：对方场上的连接怪兽的攻击力下降1000。●3种类：自己回复1500基本分。●4种类：给与对方2000伤害。●5种类：自己从卡组把1只攻击力2500以上的怪兽特殊召唤。●6种类：对方场上的攻击力3000以下的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68957925+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c68957925.target)
	e1:SetOperation(c68957925.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的连接怪兽
function c68957925.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤条件：卡组中攻击力2500以上且可以特殊召唤的怪兽
function c68957925.spfilter(c,e,tp)
	return c:IsAttackAbove(2500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：对方场上表侧表示且攻击力3000以下的怪兽
function c68957925.desfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(3000)
end
-- 效果发动时的可行性检查与操作信息设置
function c68957925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上表侧表示连接怪兽的原本属性种类数量
	local ct=Duel.GetMatchingGroup(c68957925.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetClassCount(Card.GetOriginalAttribute)
	-- 若属性种类为1，检查自己场上是否存在连接怪兽
	if chk==0 then return (ct==1 and Duel.IsExistingMatchingCard(c68957925.filter,tp,LOCATION_MZONE,0,1,nil))
		-- 若属性种类为2，检查对方场上是否存在连接怪兽
		or (ct==2 and Duel.IsExistingMatchingCard(c68957925.filter,tp,0,LOCATION_MZONE,1,nil))
		or ct==3 or ct==4
		-- 若属性种类为5，检查自己卡组是否存在满足特殊召唤条件的怪兽
		or (ct==5 and Duel.IsExistingMatchingCard(c68957925.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp))
		-- 若属性种类为6，检查对方场上是否存在满足破坏条件的怪兽
		or (ct==6 and Duel.IsExistingMatchingCard(c68957925.desfilter,tp,0,LOCATION_MZONE,1,nil)) end
	if ct==3 then
		-- 设置效果处理信息：自己回复1500基本分
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
	elseif ct==4 then
		-- 设置效果处理信息：给与对方2000伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	elseif ct==5 then
		-- 设置效果处理信息：从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif ct==6 then
		-- 获取对方场上所有满足破坏条件的怪兽
		local g=Duel.GetMatchingGroup(c68957925.desfilter,tp,0,LOCATION_MZONE,nil)
		-- 设置效果处理信息：破坏对方场上所有满足条件的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果处理的执行函数
function c68957925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上表侧表示连接怪兽的原本属性种类数量
	local ct=Duel.GetMatchingGroup(c68957925.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetClassCount(Card.GetOriginalAttribute)
	-- 获取自己场上所有的表侧表示连接怪兽
	local g1=Duel.GetMatchingGroup(c68957925.filter,tp,LOCATION_MZONE,0,nil)
	if ct==1 and g1:GetCount()>0 then
		local tc1=g1:GetFirst()
		while tc1 do
			-- ●1种类：自己场上的连接怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc1:RegisterEffect(e1)
			tc1=g1:GetNext()
		end
	end
	-- 获取对方场上所有的表侧表示连接怪兽
	local g2=Duel.GetMatchingGroup(c68957925.filter,tp,0,LOCATION_MZONE,nil)
	if ct==2 and g2:GetCount()>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		local tc2=g2:GetFirst()
		while tc2 do
			-- ●2种类：对方场上的连接怪兽的攻击力下降1000。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			tc2=g2:GetNext()
		end
	end
	if ct==3 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 执行回复自己1500基本分的操作
		Duel.Recover(tp,1500,REASON_EFFECT)
	end
	if ct==4 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 执行给与对方2000伤害的操作
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
	-- 获取自己卡组中满足特殊召唤条件的怪兽
	local g3=Duel.GetMatchingGroup(c68957925.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if ct==5 and g3:GetCount()>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g3:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 获取对方场上所有满足破坏条件的怪兽
	local g4=Duel.GetMatchingGroup(c68957925.desfilter,tp,0,LOCATION_MZONE,nil)
	if ct==6 and g4:GetCount()>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 破坏对方场上所有满足条件的怪兽
		Duel.Destroy(g4,REASON_EFFECT)
	end
end
