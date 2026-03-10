--守護神－ネフティス
-- 效果：
-- 「奈芙提斯」怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，可以从以下效果选择1个发动。
-- ●从卡组把1只鸟兽族·8星怪兽加入手卡。那之后，可以从自己墓地选1张仪式魔法卡加入手卡。
-- ●选这张卡所连接区1只「奈芙提斯」怪兽破坏，从自己墓地选原本卡名和那只怪兽不同的1只「奈芙提斯」怪兽效果无效特殊召唤。
function c50669347.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2个满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x11f),2,2)
	-- ①：这张卡是已连接召唤的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50669347,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50669347)
	e1:SetCondition(c50669347.condition)
	e1:SetTarget(c50669347.target)
	c:RegisterEffect(e1)
end
-- 判断当前怪兽是否为连接召唤 summoned
function c50669347.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索满足条件的鸟兽族8星怪兽
function c50669347.thfilter1(c)
	return c:IsLevel(8) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 检索满足条件的仪式魔法卡
function c50669347.thfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 过滤满足条件的连接区怪兽
function c50669347.desfilter(c,e,tp,g)
	-- 连接区怪兽必须是奈芙提斯族且处于正面表示状态
	return c:IsFaceup() and c:IsSetCard(0x11f) and g:IsContains(c) and Duel.GetMZoneCount(tp,c)>0
		-- 检查是否满足特殊召唤条件
		and Duel.IsExistingMatchingCard(c50669347.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤满足条件的奈芙提斯族怪兽
function c50669347.spfilter(c,e,tp,dc)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(dc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，根据选择的选项设置不同的效果分类和处理函数
function c50669347.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的鸟兽族8星怪兽
	local b1=Duel.IsExistingMatchingCard(c50669347.thfilter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查连接区是否存在满足条件的奈芙提斯族怪兽
	local b2=Duel.IsExistingMatchingCard(c50669347.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,e:GetHandler():GetLinkedGroup())
	if chk==0 then return b1 or b2 end
	local op=-1
	if b1 and b2 then
		-- 让玩家从两个选项中选择一个：检索并回收/破坏并特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(50669347,1),aux.Stringid(50669347,2))  --"检索并回收/破坏并特殊召唤"
	elseif b1 then
		-- 让玩家从一个选项中选择：检索并回收
		op=Duel.SelectOption(tp,aux.Stringid(50669347,1))  --"检索并回收"
	else
		-- 让玩家从一个选项中选择：破坏并特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(50669347,2))+1  --"破坏并特殊召唤"
	end
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetOperation(c50669347.thop)
		-- 设置操作信息，表示将从卡组检索一张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==1 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c50669347.desop)
		-- 设置操作信息，表示将破坏一张怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
		-- 设置操作信息，表示将从墓地特殊召唤一张怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- 处理检索并回收效果
function c50669347.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的鸟兽族8星怪兽
	local g=Duel.SelectMatchingCard(tp,c50669347.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 获取满足条件的仪式魔法卡
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50669347.thfilter2),tp,LOCATION_GRAVE,0,nil)
		-- 询问玩家是否从墓地检索仪式魔法卡
		if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(50669347,3)) then  --"是否从墓地把仪式魔法卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg2=g2:Select(tp,1,1,nil)
			-- 将选中的仪式魔法卡送入手牌
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		end
	end
end
-- 处理破坏并特殊召唤效果
function c50669347.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=e:GetHandler():GetLinkedGroup()
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从连接区选择满足条件的怪兽进行破坏
	local dc=Duel.SelectMatchingCard(tp,c50669347.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,lg):GetFirst()
	-- 破坏选中的怪兽
	if dc and Duel.Destroy(dc,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择满足条件的奈芙提斯族怪兽进行特殊召唤
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50669347.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,dc):GetFirst()
		-- 执行特殊召唤步骤
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 使特殊召唤的怪兽效果在回合结束时失效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
