--シュレツダー
-- 效果：
-- 从手卡把1只机械族怪兽送去墓地发动。送去墓地的怪兽的等级以下的对方场上表侧表示存在的1只怪兽破坏。这个效果1回合只能使用1次。
function c3603242.initial_effect(c)
	-- 从手卡把1只机械族怪兽送去墓地发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3603242,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c3603242.descost)
	e1:SetTarget(c3603242.destg)
	e1:SetOperation(c3603242.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手卡中是否存在满足条件的机械族怪兽（可作为效果代价）
function c3603242.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
		-- 确保在对方场上存在等级低于或等于该机械族怪兽等级的怪兽（可被破坏）
		and Duel.IsExistingTarget(c3603242.dfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 过滤函数，检查对方场上是否存在等级低于或等于指定等级的表侧表示怪兽
function c3603242.dfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
-- 效果的发动代价处理，选择并把1只手卡的机械族怪兽送去墓地
function c3603242.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手卡中是否存在符合条件的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3603242.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的手卡机械族怪兽
	local g=Duel.SelectMatchingCard(tp,c3603242.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 将选择的怪兽送去墓地作为效果的发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的发动目标选择处理，选择对方场上满足等级条件的1只怪兽
function c3603242.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c3603242.dfilter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上等级低于或等于指定等级的1只表侧表示怪兽
	local g=Duel.SelectTarget(tp,c3603242.dfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	-- 设置效果操作信息，确定破坏效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的发动处理，破坏选定的对方怪兽
function c3603242.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToEffect(e) and tc:IsLevelBelow(e:GetLabel()) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
