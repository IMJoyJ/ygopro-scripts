--封印の魔導士スプーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●从卡组把「封印之魔导士 斯彭」以外的1只「大贤者」怪兽加入手卡。
-- ●对方场上1只怪兽的攻击力直到回合结束时变成一半。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。从自己的额外卡组·墓地把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果为手牌发动，②效果为墓地发动
function s.initial_effect(c)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"丢弃发动效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- ②效果的发动需要把此卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- ①效果的发动需要丢弃此卡作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡丢入墓地作为①效果的发动代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索卡组中满足条件的「大贤者」怪兽的过滤函数
function s.filter(c)
	return not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x150)
		and c:IsAbleToHand()
end
-- ①效果的发动选择处理，根据是否满足检索和减攻条件选择发动效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「大贤者」怪兽
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	-- 检查对方场上是否存在表侧表示的怪兽
	local b2=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 向对方提示选择了“检索”效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"检索"
		op=1
	end
	if b2 and not b1 then
		-- 向对方提示选择了“攻击力变成一半”效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))  --"攻击力变成一半"
		op=2
	end
	if b1 and b2 then
		-- 调用选项选择函数，让玩家选择发动效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"检索"
			{b2,aux.Stringid(id,3),2})  --"攻击力变成一半"
	end
	if op==1 then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁操作信息，表示将要从卡组检索一张卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
-- ①效果发动后的处理，根据选择的效果类型执行对应操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的卡组中的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到被加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 显示被选为对象的怪兽
			Duel.HintSelection(g)
			-- 设置攻击力变为原来一半的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 定义装备卡的过滤函数，检查是否为「大贤者」怪兽且满足装备条件
function s.eqfilter(c,tp)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- ②效果的发动条件判断，检查是否有足够的装备区域和目标怪兽及可装备的怪兽
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查玩家装备区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 检查墓地或额外卡组是否存在满足条件的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果发动后的处理，将符合条件的怪兽装备给目标怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效且满足装备条件
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择满足条件的墓地或额外卡组中的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,tp)
		local ec=g:GetFirst()
		if ec then
			-- 尝试将装备卡装备给目标怪兽
			if not Duel.Equip(tp,ec,tc) then return end
			-- 设置装备限制效果，防止其他卡装备到同一怪兽
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制效果的判断函数，确保只能装备到指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
