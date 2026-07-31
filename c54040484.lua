--カオス・コア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡成为效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」各最多1只从手卡·卡组送去墓地，送去墓地数量的幻魔指示物给这张卡放置，这个回合自己受到的战斗伤害变成0。
-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个幻魔指示物取除。
function c54040484.initial_effect(c)
	c:EnableCounterPermit(0x57)
	-- 注册关联卡名（神炎皇 乌利亚、降雷皇 哈蒙、幻魔皇 拉比艾尔）
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：这张卡成为效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」各最多1只从手卡·卡组送去墓地，送去墓地数量的幻魔指示物给这张卡放置，这个回合自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54040484,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,54040484)
	e1:SetCondition(c54040484.countcon1)
	e1:SetTarget(c54040484.counttg)
	e1:SetOperation(c54040484.countop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(c54040484.countcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个幻魔指示物取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c54040484.reptg)
	e3:SetOperation(c54040484.repop)
	c:RegisterEffect(e3)
end
c54040484.mentioned_counter={
	[0x57]=true,
}
-- 检查这张卡是否成为效果的对象
function c54040484.countcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 检查这张卡是否被对方怪兽选择为攻击对象
function c54040484.countcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击者为对方且攻击目标为自己
	return Duel.GetAttacker():IsControler(1-tp) and e:GetHandler()==Duel.GetAttackTarget()
end
-- 筛选「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」且能送去墓地的卡
function c54040484.tgfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToGrave()
end
-- 效果①的发动条件与目标设置：检查手卡/卡组是否有三幻魔且自身能否放置指示物，并设置送墓分类信息
function c54040484.counttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡或卡组是否存在三幻魔且自身能放置幻魔指示物
	if chk==0 then return Duel.IsExistingMatchingCard(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and c:IsCanAddCounter(0x57,1) end
	-- 设置从手卡或卡组送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 检查选中的卡名互不相同且自身能放置对应数量的指示物
function c54040484.fselect(g,c)
	-- 确认选取的卡名各不相同且自身可添加等量指示物
	return aux.dncheck(g) and c:IsCanAddCounter(0x57,g:GetCount())
end
-- 效果①的处理：从手卡·卡组选择最多各1只三幻魔送去墓地，按数量放置幻魔指示物，并注册本回合战斗伤害为0的效果
function c54040484.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡和卡组中符合条件的三幻魔卡片组
	local g=Duel.GetMatchingGroup(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 弹出选择送去墓地卡片的提示框
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c54040484.fselect,false,1,g:GetCount(),c)
	-- 将选中的卡送去墓地并判断是否成功
	if sg and sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 获取实际被送去墓地的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct>0 and c:AddCounter(0x57,ct) then
			-- 这个回合自己受到的战斗伤害变成0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册本回合防止玩家受到战斗伤害的全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 代替破坏效果的目标检查：确认因战斗/效果破坏且能去除1个幻魔指示物
function c54040484.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x57,1,REASON_EFFECT)
	end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理：从这张卡上取除1个幻魔指示物
function c54040484.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x57,1,REASON_EFFECT)
end
