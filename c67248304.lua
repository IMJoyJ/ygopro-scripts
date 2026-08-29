--リバースポッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。那之后，场上的表侧表示的魔法·陷阱卡全部回到持有者手卡。并且，双方各自可以再把最多有这个效果回到自身手卡的卡数量的魔法·陷阱卡从手卡盖放。
function c67248304.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡反转的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。那之后，场上的表侧表示的魔法·陷阱卡全部回到持有者手卡。并且，双方各自可以再把最多有这个效果回到自身手卡的卡数量的魔法·陷阱卡从手卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67248304,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,67248304)
	e1:SetTarget(c67248304.target)
	e1:SetOperation(c67248304.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示可以回到手卡的魔法·陷阱卡
function c67248304.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 反转效果的目标确认与操作信息设置
function c67248304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除自身外可以变成里侧守备表示的怪兽
	local g1=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 获取场上表侧表示可以回到手卡的魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(c67248304.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置改变怪兽表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,g1:GetCount(),0,0)
	-- 设置将魔法·陷阱卡返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,g2:GetCount(),0,0)
end
-- 过滤回到自身手卡的卡片
function c67248304.ctfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 检查选取的盖放卡片是否符合魔陷区与场地区空格数量限制
function c67248304.fselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft
end
-- 执行全场怪兽变里侧、魔陷回手并从手卡盖放魔陷的效果处理
function c67248304.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身外可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将选中的怪兽全部变成里侧守备表示
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		-- 获取场上表侧表示可以回到手卡的魔法·陷阱卡
		local rg=Duel.GetMatchingGroup(c67248304.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if rg:GetCount()>0 then
			-- 中断效果处理，使之后的回手牌视为不同时处理
			Duel.BreakEffect()
			-- 将场上表侧表示的魔法·陷阱卡全部送回手卡
			if Duel.SendtoHand(rg,nil,REASON_EFFECT)==0 then return end
			-- 获取实际被送回手卡的卡片组
			local og=Duel.GetOperatedGroup()
			-- 获取当前回合玩家
			local turnp=Duel.GetTurnPlayer()
			local setg1
			-- 获取回合玩家手卡中可以盖放的魔法·陷阱卡
			local sg1=Duel.GetMatchingGroup(Card.IsSSetable,turnp,LOCATION_HAND,0,nil)
			local ct1=og:FilterCount(c67248304.ctfilter,nil,turnp)
			-- 询问回合玩家是否从手卡盖放魔法·陷阱卡
			if sg1:GetCount()>0 and ct1>0 and Duel.SelectYesNo(turnp,aux.Stringid(67248304,1)) then  --"是否把魔法·陷阱卡盖放？"
				-- 获取回合玩家魔法与陷阱区域的空余格子数
				local ft1=Duel.GetLocationCount(turnp,LOCATION_SZONE)
				-- 设置回合玩家选择盖放卡片的提示信息
				Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_SET)  --"请选择要盖放的卡"
				setg1=sg1:SelectSubGroup(turnp,c67248304.fselect,false,1,math.min(ct1,ft1+1),ft1)
			end
			local setg2
			-- 获取非回合玩家手卡中可以盖放的魔法·陷阱卡
			local sg2=Duel.GetMatchingGroup(Card.IsSSetable,1-turnp,LOCATION_HAND,0,nil)
			local ct2=og:FilterCount(c67248304.ctfilter,nil,1-turnp)
			-- 询问非回合玩家是否从手卡盖放魔法·陷阱卡
			if sg2:GetCount()>0 and ct2>0 and Duel.SelectYesNo(1-turnp,aux.Stringid(67248304,1)) then  --"是否把魔法·陷阱卡盖放？"
				-- 获取非回合玩家魔法与陷阱区域的空余格子数
				local ft2=Duel.GetLocationCount(1-turnp,LOCATION_SZONE)
				-- 设置非回合玩家选择盖放卡片的提示信息
				Duel.Hint(HINT_SELECTMSG,1-turnp,HINTMSG_SET)  --"请选择要盖放的卡"
				setg2=sg2:SelectSubGroup(1-turnp,c67248304.fselect,false,1,math.min(ct2,ft2+1),ft2)
			end
			-- 若有玩家选择盖放卡片则中断效果处理
			if setg1 or setg2 then Duel.BreakEffect() end
			-- 将回合玩家选中的魔法·陷阱卡盖放到场上
			if setg1 then Duel.SSet(turnp,setg1,turnp,false) end
			-- 将非回合玩家选中的魔法·陷阱卡盖放到场上
			if setg2 then Duel.SSet(1-turnp,setg2,1-turnp,false) end
		end
	end
end
