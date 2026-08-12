--六武式三段衝
-- 效果：
-- 自己场上有名字带有「六武众」的怪兽表侧表示3只以上存在的场合，可以从以下效果选择1个发动。
-- ●对方场上表侧表示存在的怪兽全部破坏。
-- ●对方场上表侧表示存在的魔法·陷阱卡全部破坏。
-- ●对方场上盖放的魔法·陷阱卡全部破坏。
function c81426505.initial_effect(c)
	-- 自己场上有名字带有「六武众」的怪兽表侧表示3只以上存在的场合，可以从以下效果选择1个发动。●对方场上表侧表示存在的怪兽全部破坏。●对方场上表侧表示存在的魔法·陷阱卡全部破坏。●对方场上盖放的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c81426505.descon)
	e1:SetTarget(c81426505.destg)
	e1:SetOperation(c81426505.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤表侧表示的「六武众」怪兽
function c81426505.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 发动条件：检查自己场上是否存在3只以上表侧表示的「六武众」怪兽
function c81426505.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在3只以上表侧表示的「六武众」怪兽
	return Duel.IsExistingMatchingCard(c81426505.confilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 过滤函数：过滤表侧表示的卡片（用于对方场上的表侧表示怪兽）
function c81426505.filter1(c)
	return c:IsFaceup()
end
-- 过滤函数：过滤表侧表示的魔法·陷阱卡
function c81426505.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：过滤里侧表示的卡片（用于对方场上盖放的魔法·陷阱卡）
function c81426505.filter3(c)
	return c:IsFacedown()
end
-- 效果发动时的合法性检查：检查对方场上是否存在至少一种符合破坏条件的目标
function c81426505.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		-- 检查对方场上是否存在表侧表示的怪兽
		Duel.IsExistingMatchingCard(c81426505.filter1,tp,0,LOCATION_MZONE,1,nil) or
		-- 检查对方场上是否存在表侧表示的魔法·陷阱卡
		Duel.IsExistingMatchingCard(c81426505.filter2,tp,0,LOCATION_ONFIELD,1,nil) or
		-- 检查对方场上是否存在盖放的魔法·陷阱卡
		Duel.IsExistingMatchingCard(c81426505.filter3,tp,0,LOCATION_SZONE,1,nil)
	end
	local t={}
	local p=1
	-- 若对方场上有表侧表示怪兽，则将“对方场上表侧表示存在的怪兽全部破坏”加入可选分支
	if Duel.IsExistingMatchingCard(c81426505.filter1,tp,0,LOCATION_MZONE,1,nil) then t[p]=aux.Stringid(81426505,0) p=p+1 end  --"对方表侧表示怪兽全部破坏"
	-- 若对方场上有表侧表示魔法·陷阱卡，则将“对方场上表侧表示存在的魔法·陷阱卡全部破坏”加入可选分支
	if Duel.IsExistingMatchingCard(c81426505.filter2,tp,0,LOCATION_ONFIELD,1,nil) then t[p]=aux.Stringid(81426505,1) p=p+1 end  --"对方表侧表示魔法·陷阱全部破坏"
	-- 若对方场上有盖放的魔法·陷阱卡，则将“对方场上盖放的魔法·陷阱卡全部破坏”加入可选分支
	if Duel.IsExistingMatchingCard(c81426505.filter3,tp,0,LOCATION_SZONE,1,nil) then t[p]=aux.Stringid(81426505,2) p=p+1 end  --"对方盖放的魔法·陷阱全部破坏"
	-- 提示玩家选择要发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81426505,3))  --"选择一个效果发动"
	-- 让玩家选择其中一个可发动的效果
	local sel=Duel.SelectOption(tp,table.unpack(t))+1
	local opt=t[sel]-aux.Stringid(81426505,0)  --"对方表侧表示怪兽全部破坏"
	local sg=nil
	-- 若选择第一个效果，则获取对方场上所有表侧表示的怪兽
	if opt==0 then sg=Duel.GetMatchingGroup(c81426505.filter1,tp,0,LOCATION_MZONE,nil)
	-- 若选择第二个效果，则获取对方场上所有表侧表示的魔法·陷阱卡
	elseif opt==1 then sg=Duel.GetMatchingGroup(c81426505.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 若选择第三个效果，则获取对方场上所有盖放的魔法·陷阱卡
	else sg=Duel.GetMatchingGroup(c81426505.filter3,tp,0,LOCATION_SZONE,nil) end
	-- 设置效果处理时的操作信息为破坏选定的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	e:SetLabel(opt)
end
-- 效果处理：根据玩家选择的效果，获取对应的卡片并将其全部破坏
function c81426505.desop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	local sg=nil
	-- 若发动的是第一个效果，则获取对方场上所有表侧表示的怪兽
	if opt==0 then sg=Duel.GetMatchingGroup(c81426505.filter1,tp,0,LOCATION_MZONE,nil)
	-- 若发动的是第二个效果，则获取对方场上所有表侧表示的魔法·陷阱卡
	elseif opt==1 then sg=Duel.GetMatchingGroup(c81426505.filter2,tp,0,LOCATION_ONFIELD,nil)
	-- 若发动的是第三个效果，则获取对方场上所有盖放的魔法·陷阱卡
	else sg=Duel.GetMatchingGroup(c81426505.filter3,tp,0,LOCATION_SZONE,nil) end
	-- 因效果破坏选定的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
