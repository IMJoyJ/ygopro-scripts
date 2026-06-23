--魔導皇士 アンプール
-- 效果：
-- 把这张卡以外的自己场上表侧表示存在的1只魔法师族怪兽和自己墓地1张名字带有「魔导书」的卡从游戏中除外才能发动。选择对方场上表侧表示存在的1只怪兽直到结束阶段时得到控制权。「魔导皇士 安普尔」的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
function c53136004.initial_effect(c)
	-- 创建效果，设置为起动效果，需要取对象，只能在主要怪兽区使用，每回合只能发动一次，消耗为除外自己场上1只魔法师族怪兽和墓地1张魔导书卡，发动时不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(53136004,0))  --"获得控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53136004)
	e1:SetCost(c53136004.cost)
	e1:SetTarget(c53136004.target)
	e1:SetOperation(c53136004.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查玩家场上是否存在1只正面表示的魔法师族怪兽且能作为除外的代价，并且该怪兽所在区域有可用空间
function c53136004.cfilter1(c,tp)
	-- 返回值为正面表示的魔法师族怪兽且能作为除外的代价，并且该怪兽所在区域有可用空间
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤函数：检查玩家墓地是否存在1张名字带有「魔导书」的卡且能作为除外的代价
function c53136004.cfilter2(c)
	return c:IsSetCard(0x106e) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的处理，判断是否满足发动条件（未攻击过、场上存在符合条件的魔法师族怪兽、墓地存在符合条件的魔导书卡）
function c53136004.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		-- 检查玩家场上是否存在1只正面表示的魔法师族怪兽且能作为除外的代价
		and Duel.IsExistingMatchingCard(c53136004.cfilter1,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp)
		-- 检查玩家墓地是否存在1张名字带有「魔导书」的卡且能作为除外的代价
		and Duel.IsExistingMatchingCard(c53136004.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只魔法师族怪兽并将其加入除外组
	local g1=Duel.SelectMatchingCard(tp,c53136004.cfilter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张魔导书卡并将其加入除外组
	local g2=Duel.SelectMatchingCard(tp,c53136004.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 将选中的卡从游戏中除外
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 设置效果：使这张卡在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：检查对方场上是否存在1只正面表示且能改变控制权的怪兽
function c53136004.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- 设置效果的目标，选择对方场上1只正面表示且能改变控制权的怪兽
function c53136004.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53136004.filter(chkc) end
	-- 检查对方场上是否存在1只正面表示且能改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53136004.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只正面表示且能改变控制权的怪兽作为目标
	local g=Duel.SelectTarget(tp,c53136004.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数：使目标怪兽获得控制权直到结束阶段
function c53136004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽获得控制权直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
