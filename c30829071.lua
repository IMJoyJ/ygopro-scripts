--驚楽園の大使 ＜Bufo＞
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1张「游乐设施」陷阱卡和对方场上1只怪兽为对象才能发动。那张墓地的卡给那只对方怪兽装备。
-- ②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
function c30829071.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1张「游乐设施」陷阱卡和对方场上1只怪兽为对象才能发动。那张墓地的卡给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30829071,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c30829071.eqtg1)
	e1:SetOperation(c30829071.eqop1)
	c:RegisterEffect(e1)
	-- ②：以给怪兽装备的1张自己的「游乐设施」陷阱卡为对象才能发动。那张卡给1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽装备。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30829071,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,30829071)
	e2:SetTarget(c30829071.eqtg2)
	e2:SetOperation(c30829071.eqop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为「游乐设施」陷阱卡
function c30829071.eqfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x15c)
end
-- 效果①的发动时的取对象处理，检查是否满足装备条件
function c30829071.eqtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家墓地是否存在「游乐设施」陷阱卡
		and Duel.IsExistingTarget(c30829071.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一张自己墓地的「游乐设施」陷阱卡作为装备对象
	local g1=Duel.SelectTarget(tp,c30829071.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只对方场上的表侧表示怪兽作为装备目标
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
end
-- 效果①的处理函数，执行装备操作
function c30829071.eqop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=e:GetLabelObject()
	-- 获取当前连锁中被选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,ec,tc)
		-- 设置装备限制效果，确保该装备卡只能装备给特定怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c30829071.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，判断是否能装备给指定怪兽
function c30829071.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤函数，用于判断是否为已装备的「游乐设施」陷阱卡
function c30829071.eqfilter1(c,tp)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:GetEquipTarget()
		-- 检查是否存在满足条件的「惊乐」怪兽或对方场上的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c30829071.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),tp)
end
-- 过滤函数，用于判断是否为「惊乐」怪兽或对方场上的表侧表示怪兽
function c30829071.eqfilter2(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or not c:IsControler(tp))
end
-- 效果②的发动时的取对象处理，检查是否满足装备条件
function c30829071.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c30829071.eqfilter1(chkc,tp) end
	-- 检查玩家场上是否存在已装备的「游乐设施」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c30829071.eqfilter1,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一张自己场上已装备的「游乐设施」陷阱卡
	local g=Duel.SelectTarget(tp,c30829071.eqfilter1,tp,LOCATION_SZONE,0,1,1,nil,tp)
end
-- 效果②的处理函数，执行装备操作
function c30829071.eqop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择一只满足条件的怪兽作为装备目标
		local g=Duel.SelectMatchingCard(tp,c30829071.eqfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetEquipTarget(),tp)
		local ec=g:GetFirst()
		if ec then
			-- 显示所选怪兽被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将装备卡装备给目标怪兽
			Duel.Equip(tp,tc,ec)
			-- 设置装备限制效果，确保该装备卡只能装备给特定怪兽
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c30829071.eqlimit)
			e1:SetLabelObject(ec)
			tc:RegisterEffect(e1)
		end
	end
end
