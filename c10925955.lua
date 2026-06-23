--儀水鏡との交信
-- 效果：
-- 自己场上有水属性怪兽表侧表示存在的场合，从以下效果选择1个发动。自己场上有水属性的仪式怪兽表侧表示存在的场合，可以选择两方发动。
-- ●对方的魔法与陷阱卡区域盖放的卡全部确认再回到原状。
-- ●从自己或者对方的卡组上面把2张卡确认，用喜欢的顺序回到卡组上面。
function c10925955.initial_effect(c)
	-- 创建效果，设置为魔陷发动，自由时点，条件为己方场上有水属性怪兽表侧表示，目标为选择效果，效果为发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c10925955.condition)
	e1:SetTarget(c10925955.target)
	e1:SetOperation(c10925955.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为表侧表示的水属性怪兽（可选是否为仪式怪兽）
function c10925955.cfilter(c,rit)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and (not rit or c:IsType(TYPE_RITUAL))
end
-- 效果条件函数，检查己方场上有无水属性怪兽表侧表示
function c10925955.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索己方场上有无水属性怪兽表侧表示
	return Duel.IsExistingMatchingCard(c10925955.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查是否为里侧表示且不在场地魔法区域的卡
function c10925955.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 效果目标函数，判断是否可以发动效果
function c10925955.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果：己方卡组最上方有2张以上卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 判断是否可以发动效果：对方卡组最上方有2张以上卡
		or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1
		-- 判断是否可以发动效果：对方魔法与陷阱区域有里侧表示的卡
		or Duel.IsExistingMatchingCard(c10925955.filter,tp,0,LOCATION_SZONE,1,nil) end
	local sel=0
	local ac=0
	-- 若对方魔法与陷阱区域有里侧表示的卡，则选择选项1
	if Duel.IsExistingMatchingCard(c10925955.filter,tp,0,LOCATION_SZONE,1,nil) then sel=sel+1 end
	-- 若己方或对方卡组最上方有2张以上卡，则选择选项2
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then sel=sel+2 end
	if sel==1 then
		-- 选择效果1：确认对方魔法与陷阱区域盖放的卡
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0))  --"确认对方的魔法与陷阱卡区域盖放的卡"
	elseif sel==2 then
		-- 选择效果2：确认卡组上方的两张卡
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,1))+1  --"确认卡组上方的两张卡"
	-- 若己方场上有水属性仪式怪兽表侧表示，则可选择两个效果
	elseif Duel.IsExistingMatchingCard(c10925955.cfilter,tp,LOCATION_MZONE,0,1,nil,true) then
		-- 选择效果1或2或3：确认对方魔法与陷阱区域盖放的卡
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0),aux.Stringid(10925955,1),aux.Stringid(10925955,2))  --"确认对方的魔法与陷阱卡区域盖放的卡" / "确认卡组上方的两张卡" / "两个效果都发动"
	else
		-- 选择效果1或2：确认对方魔法与陷阱区域盖放的卡
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0),aux.Stringid(10925955,1))  --"确认对方的魔法与陷阱卡区域盖放的卡" / "确认卡组上方的两张卡"
	end
	e:SetLabel(ac)
end
-- 效果发动函数，根据选择的选项执行对应效果
function c10925955.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	if ac==0 or ac==2 then
		-- 获取对方魔法与陷阱区域的里侧表示卡组
		local g=Duel.GetMatchingGroup(c10925955.filter,tp,0,LOCATION_SZONE,nil)
		-- 确认对方魔法与陷阱区域的里侧表示卡
		Duel.ConfirmCards(tp,g)
	end
	if ac==1 or ac==2 then
		-- 判断己方和对方卡组最上方是否有2张以上卡
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
			-- 选择确认己方卡组或对方卡组
			local st=Duel.SelectOption(tp,aux.Stringid(10925955,3),aux.Stringid(10925955,4))  --"确认自己的卡组"
			-- 若选择确认己方卡组，则对己方卡组最上方2张卡排序
			if st==0 then Duel.SortDecktop(tp,tp,2)
			-- 若选择确认对方卡组，则对对方卡组最上方2张卡排序
			else Duel.SortDecktop(tp,1-tp,2) end
		-- 若己方卡组最上方有2张以上卡
		elseif Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 then
			-- 对己方卡组最上方2张卡排序
			Duel.SortDecktop(tp,tp,2)
		-- 若对方卡组最上方有2张以上卡
		elseif Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
			-- 对对方卡组最上方2张卡排序
			Duel.SortDecktop(tp,1-tp,2)
		end
	end
end
