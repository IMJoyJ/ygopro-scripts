--精神汚染
-- 效果：
-- 从手卡丢弃1只怪兽才能发动。选择持有和那只怪兽相同等级的对方场上1只怪兽直到结束阶段时得到控制权。
function c69257165.initial_effect(c)
	-- 从手卡丢弃1只怪兽才能发动。选择持有和那只怪兽相同等级的对方场上1只怪兽直到结束阶段时得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c69257165.cost)
	e1:SetTarget(c69257165.target)
	e1:SetOperation(c69257165.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示、可以改变控制权且等级与丢弃怪兽相同的怪兽
function c69257165.ctffilter(c,lv)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and c:IsLevel(lv)
end
-- 过滤手卡中可以丢弃，且对方场上存在相同等级、可改变控制权的表侧表示怪兽的怪兽卡
function c69257165.ctfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		-- 检查对方场上是否存在至少1只满足相同等级且可以改变控制权等条件的表侧表示怪兽
		and Duel.IsExistingTarget(c69257165.ctffilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 暂存发动标记（由于需要先确认手卡中是否存在可作为代价丢弃且有对应等级目标的怪兽，在此将Label设为100以作标识）
function c69257165.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果发动时的处理：检查手卡中是否有可丢弃的怪兽，并让玩家选择手卡丢弃，然后选择对方场上1只相同等级的怪兽作为效果对象
function c69257165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c69257165.ctffilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己手卡中是否存在至少1只满足丢弃条件且对方场上有同等级对应目标的怪兽
		return Duel.IsExistingMatchingCard(c69257165.ctfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c69257165.ctfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local lv=sg:GetFirst():GetLevel()
	e:SetLabel(lv)
	-- 将选择的怪兽作为发动代价丢弃送去墓地
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只与丢弃怪兽相同等级、且可以改变控制权的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69257165.ctffilter,tp,0,LOCATION_MZONE,1,1,nil,lv)
	-- 设置效果处理信息为“改变1只怪兽的控制权”
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时的操作：获取选择的对象怪兽，若其仍满足条件，则直到结束阶段时得到其控制权
function c69257165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLevel(e:GetLabel()) then
		-- 得到目标怪兽的控制权，直到结束阶段时
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
