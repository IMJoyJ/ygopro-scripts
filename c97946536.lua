--ゼクトライク－紅黄
-- 效果：
-- 这个卡名在规则上也当作「甲虫装机」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：可以从手卡以及自己场上的表侧表示的卡之中把1张「甲虫装机」卡送去墓地，从以下效果选择1个发动。
-- ●从卡组选1只「甲虫装机」怪兽特殊召唤或当作装备卡使用给自己场上1只「甲虫装机」怪兽装备。
-- ●从卡组选1张「甲虫装机」装备魔法卡给自己场上1只「甲虫装机」怪兽装备。
function c97946536.initial_effect(c)
	-- ①：可以从手卡以及自己场上的表侧表示的卡之中把1张「甲虫装机」卡送去墓地，从以下效果选择1个发动。●从卡组选1只「甲虫装机」怪兽特殊召唤或当作装备卡使用给自己场上1只「甲虫装机」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97946536,0))  --"选择怪兽"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97946536+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c97946536.cost)
	e1:SetTarget(c97946536.optg)
	e1:SetOperation(c97946536.opop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(97946536,1))  --"选择魔法"
	e2:SetTarget(c97946536.eqtg)
	e2:SetOperation(c97946536.eqop)
	c:RegisterEffect(e2)
end
-- 过滤手卡或场上表侧表示的「甲虫装机」卡作为送去墓地的代价
function c97946536.tgcostfilter(c)
	return c:IsSetCard(0x56) and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 效果发动的代价：将手卡或场上表侧表示的1张「甲虫装机」卡送去墓地
function c97946536.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可以送去墓地的「甲虫装机」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97946536.tgcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向对方玩家提示选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡或场上表侧表示的1张「甲虫装机」卡
	local g=Duel.SelectMatchingCard(tp,c97946536.tgcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中可以特殊召唤或作为装备卡装备的「甲虫装机」怪兽
function c97946536.opfilter(c,e,tp,spchk,eqchk)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER)
		and (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false) or eqchk and c:CheckUniqueOnField(tp) and not c:IsForbidden())
end
-- 过滤自己场上表侧表示的「甲虫装机」怪兽
function c97946536.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 效果1（特殊召唤或装备怪兽）的发动准备与合法性检查
function c97946536.optg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有空余的怪兽区域用于特殊召唤
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否有空余的魔法与陷阱区域用于装备
		local eqchk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 并且自己场上存在可以装备的表侧表示「甲虫装机」怪兽
			and Duel.IsExistingMatchingCard(c97946536.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在满足特殊召唤或装备条件的「甲虫装机」怪兽
		return Duel.IsExistingMatchingCard(c97946536.opfilter,tp,LOCATION_DECK,0,1,nil,e,tp,spchk,eqchk)
	end
end
-- 效果1（特殊召唤或装备怪兽）的处理：从卡组选1只「甲虫装机」怪兽特殊召唤或装备
function c97946536.opop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 检查自己场上是否有空余的怪兽区域
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查自己场上是否有空余的魔法与陷阱区域
	local eqchk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在表侧表示的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c97946536.cfilter,tp,LOCATION_MZONE,0,1,nil)
	-- 玩家从卡组选择1只满足条件的「甲虫装机」怪兽
	local g=Duel.SelectMatchingCard(tp,c97946536.opfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,spchk,eqchk)
	local tc=g:GetFirst()
	if tc then
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and spchk
			-- 如果不能装备，或者玩家在选项中选择了特殊召唤
			and (not eqchk or Duel.SelectOption(tp,1152,aux.Stringid(97946536,2))==0) then  --"当作装备卡"
			-- 将选中的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 提示玩家选择要装备的对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 玩家选择自己场上1只表侧表示的「甲虫装机」怪兽作为装备对象
			local sg=Duel.SelectMatchingCard(tp,c97946536.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
			local sc=sg:GetFirst()
			if sc then
				-- 将选中的卡组怪兽作为装备卡装备给选中的场上怪兽，若装备失败则结束处理
				if not Duel.Equip(tp,tc,sc) then return end
				-- 当作装备卡使用给自己场上1只「甲虫装机」怪兽装备。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(sc)
				e1:SetValue(c97946536.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤卡组中可以装备且场上有合法装备对象的「甲虫装机」装备魔法卡
function c97946536.eqfilter(c,tp)
	return c:IsSetCard(0x56) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 并且自己场上存在该装备魔法卡可以装备的合法对象
		and Duel.IsExistingMatchingCard(c97946536.tgfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 过滤自己场上表侧表示、且是指定装备魔法卡合法装备目标的「甲虫装机」怪兽
function c97946536.tgfilter(c,eqc)
	return c:IsFaceup() and c:IsSetCard(0x56) and eqc:CheckEquipTarget(c)
end
-- 效果2（装备装备魔法）的发动准备与合法性检查
function c97946536.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且卡组中存在可以装备的「甲虫装机」装备魔法卡
		and Duel.IsExistingMatchingCard(c97946536.eqfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果2（装备装备魔法）的处理：从卡组选1张「甲虫装机」装备魔法卡给自己场上1只「甲虫装机」怪兽装备
function c97946536.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 如果自己场上仍有空余的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家从卡组选择1张「甲虫装机」装备魔法卡
		local ec=Duel.SelectMatchingCard(tp,c97946536.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if ec then
			-- 提示玩家选择要装备的对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 玩家选择自己场上1只表侧表示的「甲虫装机」怪兽作为装备对象
			local tc=Duel.SelectMatchingCard(tp,c97946536.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,ec):GetFirst()
			-- 将选中的装备魔法卡装备给选中的怪兽
			Duel.Equip(tp,ec,tc)
		end
	end
end
-- 装备限制：只能装备给作为效果处理对象的怪兽
function c97946536.eqlimit(e,c)
	return c==e:GetLabelObject()
end
