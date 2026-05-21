--ゲーテの魔導書
-- 效果：
-- 自己场上有魔法师族怪兽存在的场合，把自己墓地最多3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。为这张卡发动而除外的魔法卡数量的以下效果适用。「恶灵之魔导书」在1回合只能发动1张。
-- ●1张：选场上盖放的1张魔法·陷阱卡回到持有者手卡。
-- ●2张：选场上1只怪兽变成里侧守备表示或者表侧攻击表示。
-- ●3张：选对方场上1张卡从游戏中除外。
function c97997309.initial_effect(c)
	-- 自己场上有魔法师族怪兽存在的场合，把自己墓地最多3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。为这张卡发动而除外的魔法卡数量的以下效果适用。●1张：选场上盖放的1张魔法·陷阱卡回到持有者手卡。「恶灵之魔导书」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97997309,0))  --"1张：回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,97997309+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c97997309.condition)
	e1:SetCost(c97997309.cost)
	e1:SetTarget(c97997309.target1)
	e1:SetOperation(c97997309.activate1)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	-- 自己场上有魔法师族怪兽存在的场合，把自己墓地最多3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。为这张卡发动而除外的魔法卡数量的以下效果适用。●2张：选场上1只怪兽变成里侧守备表示或者表侧攻击表示。「恶灵之魔导书」在1回合只能发动1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97997309,1))  --"2张：改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e2:SetCountLimit(1,97997309+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c97997309.condition)
	e2:SetCost(c97997309.cost)
	e2:SetTarget(c97997309.target2)
	e2:SetOperation(c97997309.activate2)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	-- 自己场上有魔法师族怪兽存在的场合，把自己墓地最多3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。为这张卡发动而除外的魔法卡数量的以下效果适用。●3张：选对方场上1张卡从游戏中除外。「恶灵之魔导书」在1回合只能发动1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97997309,2))  --"3张：除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,97997309+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c97997309.condition)
	e3:SetCost(c97997309.cost)
	e3:SetTarget(c97997309.target3)
	e3:SetOperation(c97997309.activate3)
	e3:SetLabel(3)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c97997309.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 过滤条件：墓地中可以作为cost除外的「魔导书」魔法卡
function c97997309.rfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 发动条件：自己场上存在表侧表示的魔法师族怪兽
function c97997309.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c97997309.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价：根据所选效果，将墓地对应数量的「魔导书」魔法卡除外
function c97997309.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查墓地中是否存在足够数量的、可作为cost除外的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97997309.rfilter,tp,LOCATION_GRAVE,0,ct,nil) end
	-- 向对方玩家提示所选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择提示信息为“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地中对应数量的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c97997309.rfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	-- 将选中的卡表侧表示除外（作为发动代价）
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- 过滤条件：场上盖放的且可以返回手牌的魔法·陷阱卡
function c97997309.filter1(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果1（除外1张）的靶向处理：检查并设置操作信息
function c97997309.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除这张卡以外的、盖放的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97997309.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有盖放的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c97997309.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,e:GetHandler())
	-- 设置连锁的操作信息为“将场上1张盖放的魔法·陷阱卡送回手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果1（除外1张）的效果处理：将场上1张盖放的魔陷送回手牌
function c97997309.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1张盖放的魔法·陷阱卡（排除此卡自身）
	local g=Duel.SelectMatchingCard(tp,c97997309.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 动作为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤条件：非表侧攻击表示的怪兽，或者可以变成里侧守备表示的怪兽
function c97997309.filter2(c)
	return not c:IsPosition(POS_FACEUP_ATTACK) or c:IsCanTurnSet()
end
-- 效果2（除外2张）的靶向处理：检查并设置操作信息
function c97997309.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97997309.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有可以改变表示形式的怪兽组
	local g=Duel.GetMatchingGroup(c97997309.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息为“改变场上1只怪兽的表示形式”
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果2（除外2张）的效果处理：将场上1只怪兽变成里侧守备表示或者表侧攻击表示
function c97997309.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为“请选择要改变表示形式的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c97997309.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 动作为选中的怪兽显示被选择的动画效果
		Duel.HintSelection(g)
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			-- 若选中的怪兽是表侧攻击表示，则将其变成里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else
			-- 若选中的怪兽不是表侧攻击表示，则让玩家选择将其变成表侧攻击表示或里侧守备表示
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			-- 将选中的怪兽改变为玩家选择的表示形式
			Duel.ChangePosition(tc,pos)
		end
	end
end
-- 过滤条件：可以被除外的卡
function c97997309.filter3(c)
	return c:IsAbleToRemove()
end
-- 效果3（除外3张）的靶向处理：检查并设置操作信息
function c97997309.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以被除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c97997309.filter3,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可以被除外的卡片组
	local g=Duel.GetMatchingGroup(c97997309.filter3,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息为“除外对方场上1张卡”
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果3（除外3张）的效果处理：将对方场上1张卡除外
function c97997309.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1张卡
	local g=Duel.SelectMatchingCard(tp,c97997309.filter3,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 动作为选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的对方场上的卡表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
