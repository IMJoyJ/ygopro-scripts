--サイバー・リペア・プラント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己墓地有「电子龙」存在的场合，可以从以下效果选择1个发动（这张卡的发动时自己墓地有「电子龙」3只以上存在的场合，可以选择两方）。
-- ●从卡组把1只机械族·光属性怪兽加入手卡。
-- ●以自己墓地1只机械族·光属性怪兽为对象才能发动。那只机械族·光属性怪兽回到卡组。
function c86686671.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己墓地有「电子龙」存在的场合，可以从以下效果选择1个发动（这张卡的发动时自己墓地有「电子龙」3只以上存在的场合，可以选择两方）。●从卡组把1只机械族·光属性怪兽加入手卡。●以自己墓地1只机械族·光属性怪兽为对象才能发动。那只机械族·光属性怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,86686671+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c86686671.condition)
	e1:SetTarget(c86686671.target)
	e1:SetOperation(c86686671.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己墓地是否存在「电子龙」
function c86686671.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张卡名是「电子龙」的卡
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,70095154)
end
-- 过滤条件1：卡组中可加入手卡的机械族·光属性怪兽
function c86686671.filter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 过滤条件2：墓地中可回到卡组的机械族·光属性怪兽
function c86686671.filter2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与处理：根据墓地「电子龙」的数量，让玩家选择发动其中一个效果或同时选择两方，并进行取对象和设置操作信息等准备工作
function c86686671.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86686671.filter2(chkc) end
	-- 检查自己卡组是否存在至少1只可加入手卡的机械族·光属性怪兽（判断效果1是否可行）
	local b1=Duel.IsExistingMatchingCard(c86686671.filter1,tp,LOCATION_DECK,0,1,nil)
	-- 检查自己墓地是否存在至少1只可回到卡组的机械族·光属性怪兽（判断效果2是否可行）
	local b2=Duel.IsExistingTarget(c86686671.filter2,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 检查自己墓地是否存在3只以上的「电子龙」
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,3,nil,70095154) then
			-- 墓地有3只以上「电子龙」时，让玩家从“检索卡组”、“回收墓地”、“选择两方”中选择一个选项
			op=Duel.SelectOption(tp,aux.Stringid(86686671,0),aux.Stringid(86686671,1),aux.Stringid(86686671,2))  --"卡组检索/墓地回收/选择两方"
		else
			-- 墓地不足3只「电子龙」时，让玩家从“检索卡组”和“回收墓地”中选择一个选项
			op=Duel.SelectOption(tp,aux.Stringid(86686671,0),aux.Stringid(86686671,1))  --"卡组检索/墓地回收"
		end
	elseif b1 then
		-- 仅能发动效果1时，强制玩家选择“检索卡组”选项
		op=Duel.SelectOption(tp,aux.Stringid(86686671,0))  --"卡组检索"
	else
		-- 仅能发动效果2时，强制玩家选择“回收墓地”选项（并将选项索引加1以匹配后续逻辑）
		op=Duel.SelectOption(tp,aux.Stringid(86686671,1))+1  --"墓地回收"
	end
	e:SetLabel(op)
	if op~=0 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择自己墓地1只机械族·光属性怪兽作为效果的对象
		local g=Duel.SelectTarget(tp,c86686671.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置当前连锁的操作信息为：将选中的1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if op==1 then
			e:SetCategory(CATEGORY_TODECK)
		else
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
			-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
	else
		e:SetProperty(0)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理阶段：根据玩家在发动时选择的模式（检索、回收或两者），执行相应的卡片移动操作
function c86686671.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只满足条件的机械族·光属性怪兽
		local g=Duel.SelectMatchingCard(tp,c86686671.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入手卡，并记录操作成功的数量
			res=Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if op~=0 then
		-- 获取发动时选择的作为对象的那张墓地怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 如果选择了两方效果且检索效果成功执行，则中断效果处理，使后续的回收效果不与检索效果视为同时处理
			if op==2 and res~=0 then Duel.BreakEffect() end
			-- 将作为对象的怪兽送回持有者卡组并洗牌
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
