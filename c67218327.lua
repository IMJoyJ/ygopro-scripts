--SIMMタブラス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看，以自己墓地1只电子界族·4星怪兽为对象才能发动。这张卡从手卡往作为连接状态的自己的连接怪兽的所连接区的自己场上特殊召唤，作为对象的怪兽回到手卡。
function c67218327.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把手卡的这张卡给对方观看，以自己墓地1只电子界族·4星怪兽为对象才能发动。这张卡从手卡往作为连接状态的自己的连接怪兽的所连接区的自己场上特殊召唤，作为对象的怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67218327,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,67218327)
	e1:SetCost(c67218327.cost)
	e1:SetTarget(c67218327.target)
	e1:SetOperation(c67218327.operation)
	c:RegisterEffect(e1)
end
-- 效果发动Cost：确认手牌的这张卡未处于公开状态（用于展示手牌）
function c67218327.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选场上处于连接状态的连接怪兽
function c67218327.lkfilter(c)
	return c:IsType(TYPE_LINK) and c:IsLinkState()
end
-- 过滤函数：筛选自己墓地可以加入手牌的4星电子界族怪兽
function c67218327.filter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果发动Target：检查是否满足特殊召唤和选择墓地怪兽为对象的条件，并选择墓地的对象怪兽，声明特殊召唤和加入手牌的操作信息
function c67218327.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67218327.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		-- 获取自己场上所有处于连接状态的连接怪兽
		local lg=Duel.GetMatchingGroup(c67218327.lkfilter,tp,LOCATION_MZONE,0,nil)
		local zone=0
		-- 遍历这些连接怪兽
		for tc in aux.Next(lg) do
			zone=bit.bor(zone,bit.band(tc:GetLinkedZone(),0x1f))
		end
		return zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
			-- 检查自己场上是否有空余的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在满足条件的对象怪兽
			and Duel.IsExistingTarget(c67218327.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只满足条件的电子界族怪兽作为对象
	local g=Duel.SelectTarget(tp,c67218327.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：将手牌的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将这张卡特殊召唤到符合条件的连接区，若特殊召唤成功，则将作为对象的怪兽回到手牌
function c67218327.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己场上所有处于连接状态的连接怪兽
	local lg=Duel.GetMatchingGroup(c67218327.lkfilter,tp,LOCATION_MZONE,0,nil)
	local zone=0
	-- 遍历这些连接怪兽
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,bit.band(tc:GetLinkedZone(),0x1f))
	end
	-- 如果存在可用的连接区，则将这张卡在这些区域特殊召唤，并判断是否特殊召唤成功
	if zone~=0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽送回持有者的手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
