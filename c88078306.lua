--リセの蟲惑魔
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ②：把这张卡解放才能发动。从自己的卡组以及墓地各选1张「洞」通常陷阱卡或者「落穴」通常陷阱卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
function c88078306.initial_effect(c)
	-- ①：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c88078306.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从自己的卡组以及墓地各选1张「洞」通常陷阱卡或者「落穴」通常陷阱卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e2:SetDescription(aux.Stringid(88078306,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88078306)
	e2:SetCost(c88078306.setcost)
	e2:SetTarget(c88078306.settg)
	e2:SetOperation(c88078306.setop)
	c:RegisterEffect(e2)
end
-- 抗性过滤函数：判断效果是否为「洞」通常陷阱卡或「落穴」通常陷阱卡的效果
function c88078306.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 过滤函数：判断卡片是否为可盖放的「洞」通常陷阱卡或「落穴」通常陷阱卡
function c88078306.setfilter(c)
	return c:IsSetCard(0x4c,0x89) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 选择条件函数：检查卡片组中的卡片是否分别来自不同的区域（卡组和墓地各一张）且卡名不同
function c88078306.fselect(g)
	-- 返回是否满足“卡片来源区域不同（卡组和墓地各1张）且卡名不同”的条件
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and aux.dncheck(g)
end
-- 效果②的发动代价（Cost）函数
function c88078306.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备（Target）函数
function c88078306.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组及墓地中所有满足条件的「洞」或「落穴」通常陷阱卡
	local g=Duel.GetMatchingGroup(c88078306.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 在chk为0时，检查魔法与陷阱区域是否有2个以上的空位，且卡组和墓地中存在满足条件（各选1张且卡名不同）的2张卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2 and g:CheckSubGroup(c88078306.fselect,2,2) end
	-- 设置操作信息：包含涉及墓地移动卡片的操作（从墓地移出1张卡）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果②的效果处理（Operation）函数
function c88078306.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域的空位不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	-- 获取自己卡组及墓地中满足条件且不受「王家之谷」影响的「洞」或「落穴」通常陷阱卡
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c88078306.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local sg=g:SelectSubGroup(tp,c88078306.fselect,false,2,2)
	if sg and #sg==2 then
		-- 将选中的卡在自己场上盖放，若盖放失败则结束处理
		if Duel.SSet(tp,sg)==0 then return end
		local tc=sg:GetFirst()
		while tc do
			-- 这个效果盖放的卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end
	end
end
