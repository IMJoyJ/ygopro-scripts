--先史遺産コロッサル・ヘッド
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择场上攻击表示存在的1只3星以上的怪兽才能发动。选择的怪兽变成表侧守备表示或者里侧守备表示。「先史遗产 巨石人头像」的效果1回合只能使用1次。
function c52158283.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择场上攻击表示存在的1只3星以上的怪兽才能发动。选择的怪兽变成表侧守备表示或者里侧守备表示。「先史遗产 巨石人头像」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52158283,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,52158283)
	-- 设置效果的发动代价为：把墓地中的这张卡从游戏中除外（作为发动COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c52158283.target)
	e1:SetOperation(c52158283.operation)
	c:RegisterEffect(e1)
end
-- 定义效果可选择的对象条件：场上攻击表示且等级3星以上的怪兽。
function c52158283.filter(c)
	return c:IsAttackPos() and c:IsLevelAbove(3)
end
-- 效果发动时的对象选定处理：校验对象合法性，确认场上存在可选对象，然后让玩家从场上选择1只符合条件的怪兽作为对象，并登记改变表示形式的操作信息。
function c52158283.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52158283.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只满足条件的攻击表示3星以上怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c52158283.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从场上选择1只满足条件的攻击表示3星以上怪兽，并将其设为该连锁的效果对象。
	local g=Duel.SelectTarget(tp,c52158283.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记处理信息：本连锁后续将处理1张卡（对象怪兽）的表示形式变更（CATEGORY_POSITION），用于相关效果的时点/连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理阶段的操作：取出对象怪兽，若其仍与效果关联，则根据其当前表示形式处理；攻击表示时由玩家选择变为表侧守备或里侧守备（不能里侧则只能表侧），非攻击表示时则在表侧守备与里侧守备之间切换，最终改变其表示形式。
function c52158283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动时所选择的对象怪兽（本效果只选择1只）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsAttackPos() then
			local pos=0
			if tc:IsCanTurnSet() then
				-- 当对象可以变成里侧守备表示时，让玩家从表侧守备表示和里侧守备表示中选择一种作为新的表示形式。
				pos=Duel.SelectPosition(tp,tc,POS_DEFENSE)
			else
				-- 当对象不能变成里侧表示时，让玩家选择表侧守备表示作为新的表示形式。
				pos=Duel.SelectPosition(tp,tc,POS_FACEUP_DEFENSE)
			end
			-- 将对象怪兽的表示形式变更为所选的形式（表侧守备或里侧守备）。
			Duel.ChangePosition(tc,pos)
		else
			-- 当对象在效果处理时已不是攻击表示（已处于守备表示）时，将其变为相反的守备形式：表侧守备变里侧守备，里侧守备变表侧守备，以满足“变成表侧守备表示或里侧守备表示”的要求。
			Duel.ChangePosition(tc,0,0,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE)
		end
	end
end
