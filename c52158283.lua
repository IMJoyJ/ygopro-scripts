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
	-- 将此卡从墓地除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c52158283.target)
	e1:SetOperation(c52158283.operation)
	c:RegisterEffect(e1)
end
-- 筛选场上攻击表示且等级3以上的怪兽
function c52158283.filter(c)
	return c:IsAttackPos() and c:IsLevelAbove(3)
end
-- 选择符合条件的怪兽作为效果对象
function c52158283.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52158283.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c52158283.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52158283.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果的发动，改变目标怪兽的表示形式
function c52158283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsAttackPos() then
			local pos=0
			if tc:IsCanTurnSet() then
				-- 选择怪兽变为里侧守备表示
				pos=Duel.SelectPosition(tp,tc,POS_DEFENSE)
			else
				-- 选择怪兽变为表侧守备表示
				pos=Duel.SelectPosition(tp,tc,POS_FACEUP_DEFENSE)
			end
			-- 将目标怪兽改变为指定表示形式
			Duel.ChangePosition(tc,pos)
		else
			-- 将目标怪兽强制变为守备表示
			Duel.ChangePosition(tc,0,0,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE)
		end
	end
end
