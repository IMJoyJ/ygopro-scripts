--カオス・コア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡成为效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」各最多1只从手卡·卡组送去墓地，送去墓地数量的幻魔指示物给这张卡放置，这个回合自己受到的战斗伤害变成0。
-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个幻魔指示物取除。
function c54040484.initial_effect(c)
	c:EnableCounterPermit(0x57)
	-- 注册该卡记有「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」的卡片密码。
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
-- 成为效果对象时效果的发动条件判定。
function c54040484.countcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 被选择作为对方怪兽的攻击对象时效果的发动条件判定。
function c54040484.countcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制，且自身是否为攻击目标。
	return Duel.GetAttacker():IsControler(1-tp) and e:GetHandler()==Duel.GetAttackTarget()
end
-- 过滤手卡或卡组中可以送去墓地的「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」。
function c54040484.tgfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToGrave()
end
-- ①的效果的发动准备与合法性检测。
function c54040484.counttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡或卡组是否存在至少1张符合条件的卡，且自身能否放置至少1个幻魔指示物。
	if chk==0 then return Duel.IsExistingMatchingCard(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and c:IsCanAddCounter(0x57,1) end
	-- 设置将手卡或卡组的卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤出卡名各不相同且数量不超过自身可放置指示物上限的卡片组。
function c54040484.fselect(g,c)
	-- 检查卡片组内卡名是否各不相同，且自身能否放置等同于该卡片组数量的指示物。
	return aux.dncheck(g) and c:IsCanAddCounter(0x57,g:GetCount())
end
-- ①的效果的处理逻辑（送墓、放置指示物、伤害变0）。
function c54040484.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡和卡组中所有符合条件的「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」。
	local g=Duel.GetMatchingGroup(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c54040484.fselect,false,1,g:GetCount(),c)
	-- 将选中的卡送去墓地，并判断是否成功送去至少1张。
	if sg and sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 获取实际被送去墓地的卡片组。
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct>0 and c:AddCounter(0x57,ct) then
			-- 这个回合自己受到的战斗伤害变成0。②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个幻魔指示物取除。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册“这个回合自己受到的战斗伤害变成0”的玩家效果。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 代替破坏效果的条件与合法性检测。
function c54040484.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x57,1,REASON_EFFECT)
	end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 执行代替破坏的操作，取除这张卡的1个幻魔指示物。
function c54040484.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x57,1,REASON_EFFECT)
end
