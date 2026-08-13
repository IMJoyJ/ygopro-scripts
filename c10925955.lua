--儀水鏡との交信
-- 效果：
-- 自己场上有水属性怪兽表侧表示存在的场合，从以下效果选择1个发动。自己场上有水属性的仪式怪兽表侧表示存在的场合，可以选择两方发动。
-- ●对方的魔法与陷阱卡区域盖放的卡全部确认再回到原状。
-- ●从自己或者对方的卡组上面把2张卡确认，用喜欢的顺序回到卡组上面。
function c10925955.initial_effect(c)
	-- 自己场上有水属性怪兽表侧表示存在的场合，从以下效果选择1个发动。自己场上有水属性的仪式怪兽表侧表示存在的场合，可以选择两方发动。●对方的魔法与陷阱卡区域盖放的卡全部确认再回到原状。●从自己或者对方的卡组上面把2张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c10925955.condition)
	e1:SetTarget(c10925955.target)
	e1:SetOperation(c10925955.activate)
	c:RegisterEffect(e1)
end
-- cfilter函数：检查卡是否为表侧表示且水属性；当rit参数为true时，额外要求该卡是仪式怪兽，用于区分普通水属性怪兽与水属性仪式怪兽。
function c10925955.cfilter(c,rit)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and (not rit or c:IsType(TYPE_RITUAL))
end
-- condition函数：该卡的发动条件，只要自己场上有表侧表示的水属性怪兽存在即可发动。
function c10925955.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索己方场上主要怪兽区是否存在至少1只表侧表示的水属性怪兽（不含额外要求类型的判断）。
	return Duel.IsExistingMatchingCard(c10925955.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- filter函数：筛选对方魔法与陷阱卡区域里侧表示、且不在场地魔法格（序列号5）的卡，即通常的魔法·陷阱区域里侧盖卡。
function c10925955.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- target函数：效果发动时的目标判定与选项选择处理，先检查可选分支的合法性，再让玩家选择发动哪个效果。
function c10925955.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组是否有至少2张卡，用于判断能否选择‘确认自己卡组上方2张’这一分支。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 检查对方的卡组是否有至少2张卡，用于判断能否选择‘确认对方卡组上方2张’这一分支。
		or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1
		-- 检查对方魔陷区是否存在里侧表示且非场地魔法的盖卡，用于判断能否选择‘确认对方魔陷区盖放卡’这一分支。
		or Duel.IsExistingMatchingCard(c10925955.filter,tp,0,LOCATION_SZONE,1,nil) end
	local sel=0
	local ac=0
	-- 若存在符合条件的对方里侧魔陷，则可选分支计数加1，表示可以选择确认对方魔陷区盖卡。
	if Duel.IsExistingMatchingCard(c10925955.filter,tp,0,LOCATION_SZONE,1,nil) then sel=sel+1 end
	-- 若自己或对方任一卡组至少有2张卡，则可选分支计数加2，表示可以选择确认卡组上方2张卡。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then sel=sel+2 end
	if sel==1 then
		-- 当只能选择确认对方魔陷区盖卡时，直接让玩家选择该选项，选择结果ac=0表示执行第一个效果。
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0))  --"确认对方的魔法与陷阱卡区域盖放的卡"
	elseif sel==2 then
		-- 当只能选择确认卡组上方2张卡时，让玩家选择该选项，选择结果加上1后ac=1表示执行第二个效果。
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,1))+1  --"确认卡组上方的两张卡"
	-- 若两个效果都可选，再检查自己场上是否有表侧表示的水属性仪式怪兽，以决定是否提供‘两个效果都使用’的选项。
	elseif Duel.IsExistingMatchingCard(c10925955.cfilter,tp,LOCATION_MZONE,0,1,nil,true) then
		-- 存在水属性仪式怪兽时，提供三个选项：确认对方魔陷区盖卡、确认卡组上方2张、两个效果都使用；选择结果直接作为ac值（0/1/2）。
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0),aux.Stringid(10925955,1),aux.Stringid(10925955,2))  --"确认对方的魔法与陷阱卡区域盖放的卡/确认卡组上方的两张卡/两个效果都使用"
	else
		-- 没有水属性仪式怪兽时，只提供两个选项：确认对方魔陷区盖卡或确认卡组上方2张；选择结果作为ac值（0/1）。
		ac=Duel.SelectOption(tp,aux.Stringid(10925955,0),aux.Stringid(10925955,1))  --"确认对方的魔法与陷阱卡区域盖放的卡/确认卡组上方的两张卡"
	end
	e:SetLabel(ac)
end
-- activate函数：实际处理选定的效果。ac为0或2时确认对方里侧魔陷；ac为1或2时选择并排序卡组上方2张卡。
function c10925955.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	if ac==0 or ac==2 then
		-- 获取对方魔陷区中所有里侧表示且不在场地魔法格的卡组成的集合。
		local g=Duel.GetMatchingGroup(c10925955.filter,tp,0,LOCATION_SZONE,nil)
		-- 将上述里侧盖卡展示给己方玩家确认，确认后仍恢复里侧表示回到原状。
		Duel.ConfirmCards(tp,g)
	end
	if ac==1 or ac==2 then
		-- 当自己与对方的卡组都各有至少2张卡时，需要进一步让玩家选择确认的是哪个卡组。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
			-- 让玩家选择‘确认自己的卡组’或‘确认对方的卡组’，返回选择结果st。
			local st=Duel.SelectOption(tp,aux.Stringid(10925955,3),aux.Stringid(10925955,4))  --"确认自己的卡组/确认对方的卡组"
			-- 若选择自己的卡组，则对己方卡组最上方2张卡进行排序（由己方按喜好顺序放回）。
			if st==0 then Duel.SortDecktop(tp,tp,2)
			-- 若选择对方的卡组，则对对方卡组最上方2张卡进行排序（由己方按喜好顺序放回）。
			else Duel.SortDecktop(tp,1-tp,2) end
		-- 若只有自己的卡组满足至少2张，则无需选择，直接进入确认自己卡组的分支。
		elseif Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 then
			-- 确认自己卡组最上方2张卡，并让己方玩家按喜好顺序放回卡组上方。
			Duel.SortDecktop(tp,tp,2)
		-- 若只有对方的卡组满足至少2张，则无需选择，直接进入确认对方卡组的分支。
		elseif Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>1 then
			-- 确认对方卡组最上方2张卡，并让己方玩家按喜好顺序放回对方卡组上方。
			Duel.SortDecktop(tp,1-tp,2)
		end
	end
end
