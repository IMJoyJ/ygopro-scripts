--スターライト・ロード
-- 效果：
-- ①：要让自己场上的卡2张以上破坏的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效并破坏。那之后，可以把1只「星尘龙」从额外卡组特殊召唤。
function c58120309.initial_effect(c)
	-- 在卡片中注册记载了「星尘龙」的卡名
	aux.AddCodeList(c,44508094)
	-- ①：要让自己场上的卡2张以上破坏的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效并破坏。那之后，可以把1只「星尘龙」从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c58120309.condition)
	e1:SetTarget(c58120309.target)
	e1:SetOperation(c58120309.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否由自己控制且在场上
function c58120309.filter(c,p)
	return c:GetControler()==p and c:IsOnField()
end
-- 发动条件：检查被连锁的效果是否包含破坏自己场上2张以上卡的操作
function c58120309.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前连锁的效果无法被无效，则不能发动此卡
	if not Duel.IsChainNegatable(ev) then return false end
	-- 获取当前连锁中关于破坏效果的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c58120309.filter,nil,tp)-tg:GetCount()>1
end
-- 过滤条件：筛选额外卡组中可以特殊召唤的「星尘龙」
function c58120309.sfilter(c,e,tp)
	-- 检查卡片是否为「星尘龙」、是否可以特殊召唤，以及额外卡组怪兽出场区域是否有空位
	return c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果的目标处理：设置效果无效与破坏的操作信息
function c58120309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：此效果包含使发动效果的卡无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：此效果包含破坏发动效果的卡的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的运行处理：使效果无效并破坏，之后可以选择特殊召唤「星尘龙」
function c58120309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该效果无效，若成功且该卡与效果相关，则将其破坏
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 从额外卡组中寻找第一张符合特殊召唤条件的「星尘龙」
		local sc=Duel.GetFirstMatchingCard(c58120309.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		-- 若存在符合条件的「星尘龙」，则询问玩家是否选择进行特殊召唤
		if sc and Duel.SelectYesNo(tp,aux.Stringid(58120309,0)) then  --"是否要特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与前面的无效破坏不视为同时处理
			Duel.BreakEffect()
			-- 将选定的「星尘龙」以表侧表示特殊召唤到场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
