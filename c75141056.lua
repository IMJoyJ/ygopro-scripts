--ヒーロー・マスク
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从卡组把1只「元素英雄」怪兽送去墓地，作为对象的自己的表侧表示怪兽直到结束阶段当作和这个效果送去墓地的怪兽同名卡使用。
function c75141056.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。从卡组把1只「元素英雄」怪兽送去墓地，作为对象的自己的表侧表示怪兽直到结束阶段当作和这个效果送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c75141056.target)
	e1:SetOperation(c75141056.activate)
	c:RegisterEffect(e1)
end
-- 定义作为效果对象的怪兽的过滤条件（必须是表侧表示，且卡组中存在至少1只与其卡名不同、可送去墓地的「元素英雄」怪兽）
function c75141056.tgfilter(c)
	-- 过滤条件为：该怪兽在场上表侧表示，且卡组中存在至少1只与其卡名不同、可送去墓地的「元素英雄」怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c75141056.cfilter,c:GetControler(),LOCATION_DECK,0,1,nil,c)
end
-- 定义从卡组送去墓地的「元素英雄」怪兽的过滤条件（属于「元素英雄」系列、与目标怪兽卡名不同、是怪兽卡、且能送去墓地）
function c75141056.cfilter(c,tc)
	return c:IsSetCard(0x3008) and not c:IsCode(tc:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动时的对象选择与合法性检查（Target阶段）
function c75141056.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c75141056.tgfilter(chkc) end
	-- 在发动效果的准备阶段，检查自己场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c75141056.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择1张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只满足条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c75141056.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理的执行函数（Resolution阶段）
function c75141056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只与目标怪兽卡名不同的「元素英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c75141056.cfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 如果成功将选中的怪兽送去墓地，且该怪兽确实到达墓地，同时作为对象的怪兽仍表侧表示存在于场上
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 作为对象的自己的表侧表示怪兽直到结束阶段当作和这个效果送去墓地的怪兽同名卡使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(gc:GetCode())
			tc:RegisterEffect(e1)
		end
	end
end
