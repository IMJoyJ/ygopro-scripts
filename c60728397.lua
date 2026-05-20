--ヴェノム・ショット
-- 效果：
-- 自己场上有「毒蛇王 维诺米隆」「毒蛇神 维诺米纳迦」或者名字带有「蛇毒」的怪兽表侧表示存在时才能发动。从自己卡组把1只爬虫类族怪兽送去墓地，给对方场上表侧表示存在的1只怪兽放置2个毒指示物。
function c60728397.initial_effect(c)
	-- 自己场上有「毒蛇王 维诺米隆」「毒蛇神 维诺米纳迦」或者名字带有「蛇毒」的怪兽表侧表示存在时才能发动。从自己卡组把1只爬虫类族怪兽送去墓地，给对方场上表侧表示存在的1只怪兽放置2个毒指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c60728397.condition)
	e1:SetTarget(c60728397.target)
	e1:SetOperation(c60728397.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「毒蛇王 维诺米隆」、「毒蛇神 维诺米纳迦」或「蛇毒」系列怪兽
function c60728397.cfilter(c)
	return c:IsFaceup() and (c:IsCode(72677437,8062132) or c:IsSetCard(0x50))
end
-- 发动条件：检查自己场上是否存在满足过滤条件的怪兽
function c60728397.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「毒蛇王 维诺米隆」、「毒蛇神 维诺米纳迦」或「蛇毒」怪兽
	return Duel.IsExistingMatchingCard(c60728397.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地的爬虫类族怪兽
function c60728397.tgfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
-- 效果发动时的目标选择与合法性检查（包括取对象和卡组送墓检查）
function c60728397.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,2) end
	-- 在发动时，检查对方场上是否存在至少1只可以放置2个毒指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,2)
		-- 并且检查自己卡组是否存在至少1只可以送去墓地的爬虫类族怪兽
		and Duel.IsExistingMatchingCard(c60728397.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可以放置2个毒指示物的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,2)
	-- 设置操作信息：包含放置指示物的效果分类
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理：从卡组将1只爬虫类族怪兽送去墓地，并给作为对象的怪兽放置2个毒指示物
function c60728397.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c60728397.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡组怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 获取发动时选择的作为对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,2) and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			local atk=tc:GetAttack()
			tc:AddCounter(0x1009,2)
			if atk>0 and tc:IsAttack(0) then
				-- 触发自定义事件（通知「蛇毒沼泽」等相关卡片进行攻击力变为0时的怪兽破坏处理）
				Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
			end
		end
	end
end
