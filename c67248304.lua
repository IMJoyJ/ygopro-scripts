--リバースポッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。那之后，场上的表侧表示的魔法·陷阱卡全部回到持有者手卡。并且，双方各自可以再把最多有这个效果回到自身手卡的卡数量的魔法·陷阱卡从手卡盖放。
function c67248304.initial_effect(c)
	-- ①：这张卡反转的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。那之后，场上的表侧表示的魔法·陷阱卡全部回到持有者手卡。并且，双方各自可以再把最多有这个效果回到自身手卡的卡数量的魔法·陷阱卡从手卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67248304,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,67248304)
	e1:SetTarget(c67248304.target)
	e1:SetOperation(c67248304.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且可以回到手牌的魔法·陷阱卡
function c67248304.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标确认与操作信息设置
function c67248304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡以外所有可以变成里侧表示的怪兽
	local g1=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 获取场上所有表侧表示的魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(c67248304.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,g1:GetCount(),0,0)
	-- 设置回到手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,g2:GetCount(),0,0)
end
-- 过滤因该效果回到某玩家手牌的卡片
function c67248304.ctfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 限制盖放的魔法·陷阱卡数量，确保场地魔法最多1张且普通魔陷不超过魔陷区空位数
function c67248304.fselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft
end
-- 效果处理的完整逻辑（改变怪兽表示形式、回手牌、双方盖放魔陷）
function c67248304.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将这些怪兽全部变成里侧守备表示，若成功则继续处理
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取场上所有表侧表示的魔法·陷阱卡
		local rg=Duel.GetMatchingGroup(c67248304.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if rg:GetCount()>0 then
			-- 中断当前效果，用于“那之后”的时点处理
			Duel.BreakEffect()
			-- 将场上的表侧表示魔法·陷阱卡全部回到持有者手卡，若无卡片回到手牌则结束效果
			if Duel.SendtoHand(rg,nil,REASON_EFFECT)==0 then return end
			-- 获取实际回到手牌的卡片组
			local og=Duel.GetOperatedGroup()
			-- 获取当前回合玩家
			local turnp=Duel.GetTurnPlayer()
			local setg1=Group.CreateGroup()
			-- 获取回合玩家手牌中可以盖放的魔法·陷阱卡
			local sg1=Duel.GetMatchingGroup(Card.IsSSetable,turnp,LOCATION_HAND,0,nil)
			local ct1=og:FilterCount(c67248304.ctfilter,nil,turnp)
			-- 若回合玩家有可盖放的卡且有卡片因此效果回到其手牌，询问其是否盖放
			if sg1:GetCount()>0 and ct1>0 and Duel.SelectYesNo(turnp,aux.Stringid(67248304,1)) then  --"是否把魔法·陷阱卡盖放？"
				-- 获取回合玩家魔陷区的可用空格数
				local ft1=Duel.GetLocationCount(turnp,LOCATION_SZONE)
				-- 提示回合玩家选择要盖放的卡
				Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_SET)  --"请选择要盖放的卡"
				setg1=sg1:SelectSubGroup(turnp,c67248304.fselect,false,1,math.min(ct1,ft1+1),ft1)
			end
			local setg2=Group.CreateGroup()
			-- 获取非回合玩家手牌中可以盖放的魔法·陷阱卡
			local sg2=Duel.GetMatchingGroup(Card.IsSSetable,1-turnp,LOCATION_HAND,0,nil)
			local ct2=og:FilterCount(c67248304.ctfilter,nil,1-turnp)
			-- 若非回合玩家有可盖放的卡且有卡片因此效果回到其手牌，询问其是否盖放
			if sg2:GetCount()>0 and ct2>0 and Duel.SelectYesNo(1-turnp,aux.Stringid(67248304,1)) then  --"是否把魔法·陷阱卡盖放？"
				-- 获取非回合玩家魔陷区的可用空格数
				local ft2=Duel.GetLocationCount(1-turnp,LOCATION_SZONE)
				-- 提示非回合玩家选择要盖放的卡
				Duel.Hint(HINT_SELECTMSG,1-turnp,HINTMSG_SET)  --"请选择要盖放的卡"
				setg2=sg2:SelectSubGroup(1-turnp,c67248304.fselect,false,1,math.min(ct2,ft2+1),ft2)
			end
			-- 若有玩家选择盖放卡片，则中断当前效果，使盖放处理视为不同时处理
			if setg1:GetCount()>0 or setg2:GetCount()>0 then Duel.BreakEffect() end
			-- 回合玩家将选定的魔法·陷阱卡在自身场上盖放
			if setg1:GetCount()>0 then Duel.SSet(turnp,setg1,turnp,false) end
			-- 非回合玩家将选定的魔法·陷阱卡在自身场上盖放
			if setg2:GetCount()>0 then Duel.SSet(1-turnp,setg2,1-turnp,false) end
		end
	end
end
