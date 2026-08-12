--カオス・コア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡成为效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」各最多1只从手卡·卡组送去墓地，送去墓地数量的幻魔指示物给这张卡放置，这个回合自己受到的战斗伤害变成0。
-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个幻魔指示物取除。
function c54040484.initial_effect(c)
	c:EnableCounterPermit(0x57)
	-- 在脚本中记录这张卡上记载着「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的卡名
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡成为效果的对象时才能发动。「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」各最多1只从手卡·卡组送去墓地，送去墓地数量的幻魔指示物给这张卡放置，这个回合自己受到的战斗伤害变成0。
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
-- 发动条件：检查成为效果对象的卡中是否包含这张卡本身
function c54040484.countcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- 发动条件：确认这张卡被选择作为对方怪兽的攻击对象
function c54040484.countcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击宣言的怪兽由对方控制，且这张卡正是此次攻击的对象时满足发动条件
	return Duel.GetAttacker():IsControler(1-tp) and e:GetHandler()==Duel.GetAttackTarget()
end
-- 过滤条件：卡名为「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」之一且可以送去墓地
function c54040484.tgfilter(c)
	return c:IsCode(6007213,32491822,69890967) and c:IsAbleToGrave()
end
-- 发动的取对象阶段：确认手卡·卡组存在可送去墓地的幻魔怪兽且这张卡可以放置幻魔指示物，并设置送去墓地的操作信息
function c54040484.counttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己手卡·卡组是否存在至少1张满足条件的卡，并且这张卡可以放置1个幻魔指示物
	if chk==0 then return Duel.IsExistingMatchingCard(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and c:IsCanAddCounter(0x57,1) end
	-- 设置操作信息：预计把自己手卡·卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 选择子卡组的过滤条件：所选卡名互不相同且这张卡能放置所选数量的幻魔指示物
function c54040484.fselect(g,c)
	-- 所选卡片组的卡名必须互不相同，且这张卡可以放置与该数量相同的幻魔指示物
	return aux.dncheck(g) and c:IsCanAddCounter(0x57,g:GetCount())
end
-- 效果处理：从手卡·卡组选出满足条件的幻魔怪兽送去墓地，按送去墓地的数量给这张卡放置幻魔指示物，并注册这个回合自己不受战斗伤害的效果
function c54040484.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索自己手卡·卡组中所有满足条件的幻魔怪兽
	local g=Duel.GetMatchingGroup(c54040484.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 向玩家提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c54040484.fselect,false,1,g:GetCount(),c)
	-- 确认选出了至少1张卡，并将所选卡片因效果送去墓地
	if sg and sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		-- 取得刚才送墓操作实际送去墓地的卡片组
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
			-- 把「自己不受战斗伤害」的效果注册给发动效果的玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 代替破坏的适用条件：这张卡被战斗或效果破坏且不是被其他代替效果破坏，并能取除1个幻魔指示物
function c54040484.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x57,1,REASON_EFFECT)
	end
	-- 询问玩家是否发动这个代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为破坏的代替，把这张卡1个幻魔指示物取除
function c54040484.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x57,1,REASON_EFFECT)
end
