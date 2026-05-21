--犬タウルス
-- 效果：
-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时才能发动。从手卡·卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地，这张卡的攻击力直到战斗阶段结束时上升送去墓地的那只怪兽的等级×100。
function c91754175.initial_effect(c)
	-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时才能发动。从手卡·卡组把1只兽族·兽战士族·鸟兽族怪兽送去墓地，这张卡的攻击力直到战斗阶段结束时上升送去墓地的那只怪兽的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91754175,0))  --"是否发动「人犬兽」的效果？"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c91754175.condition)
	e1:SetTarget(c91754175.target)
	e1:SetOperation(c91754175.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡与对方怪兽进行战斗（存在战斗对象）。
function c91754175.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()
end
-- 过滤条件：手卡·卡组中可以送去墓地的兽族、兽战士族或鸟兽族怪兽。
function c91754175.tgfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToGrave()
end
-- 效果发动：检查手卡·卡组中是否存在符合条件的怪兽，并设置送去墓地的操作信息。
function c91754175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认手卡或卡组中是否存在至少1只可以送去墓地的兽族·兽战士族·鸟兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c91754175.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将手卡或卡组的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：将手卡·卡组的1只符合条件的怪兽送去墓地，若成功且自身仍在场上，则使自身攻击力上升该怪兽等级×100的数值。
function c91754175.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡或卡组中选择1只满足条件的兽族·兽战士族·鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c91754175.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	-- 判断选中的怪兽是否成功因效果送去墓地且存在于墓地中。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToBattle() and c:IsFaceup() then
		local lv=tc:GetLevel()
		-- 这张卡的攻击力直到战斗阶段结束时上升送去墓地的那只怪兽的等级×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
