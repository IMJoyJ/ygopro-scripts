--奇跡のマジック・ゲート
-- 效果：
-- ①：自己场上有魔法师族怪兽2只以上存在的场合才能发动。选对方场上1只攻击表示怪兽变成守备表示。那之后，得到那只怪兽的控制权。这个效果得到控制权的怪兽不会被战斗破坏。
function c49941059.initial_effect(c)
	-- 效果定义：发动条件为己方场上存在2只以上魔法师族怪兽，效果发动时选择对方场上的1只攻击表示怪兽变为守备表示，并获得其控制权，且该怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c49941059.condition)
	e1:SetTarget(c49941059.target)
	e1:SetOperation(c49941059.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查己方场上是否存在表侧表示的魔法师族怪兽。
function c49941059.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件判断：检查己方场上是否存在至少2张满足cfilter条件的怪兽。
function c49941059.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少2张满足cfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(c49941059.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 目标过滤函数：检查对方场上的怪兽是否为攻击表示、可以改变表示形式且可以变更控制权。
function c49941059.tgfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and c:IsControlerCanBeChanged()
end
-- 效果处理目标设定：判断是否能选择对方场上的1只攻击表示怪兽作为目标，并设置操作信息。
function c49941059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能选择对方场上的1只攻击表示怪兽作为目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c49941059.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：将对方场上的怪兽表示形式改变作为处理对象。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
	-- 设置操作信息：将对方场上的怪兽控制权变更作为处理对象。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理流程：选择对方场上的一只攻击表示怪兽变为守备表示，并获得其控制权，若成功则赋予该怪兽不会被战斗破坏的效果。
function c49941059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择目标怪兽：向玩家发送提示信息“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的目标怪兽：从对方场上选择一只攻击表示且可变更位置和控制权的怪兽。
	local g=Duel.SelectMatchingCard(tp,c49941059.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local c=g:GetFirst()
	-- 将选中的怪兽变为守备表示：若目标怪兽存在且成功改变其表示形式，则继续处理。
	if c and Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)>0 then
		-- 中断当前效果处理：使后续效果处理视为不同时处理，防止错时点。
		Duel.BreakEffect()
		-- 获得目标怪兽的控制权：若成功获得控制权，则为该怪兽添加不会被战斗破坏的效果。
		if Duel.GetControl(c,tp)>0 then
			-- 设置永续效果：为获得控制权的怪兽添加不会被战斗破坏的效果。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
