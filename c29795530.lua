--妖怪のいたずら
-- 效果：
-- ①：场上的全部怪兽的等级直到回合结束时下降2星。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时下降1星。这个效果在这张卡送去墓地的回合不能发动。
function c29795530.initial_effect(c)
	-- ①：场上的全部怪兽的等级直到回合结束时下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c29795530.target)
	e1:SetOperation(c29795530.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时下降1星。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29795530,0))  --"等级下降"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（通过aux.exccon判断）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地的这张卡除外（通过aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29795530.lvtg)
	e2:SetOperation(c29795530.lvop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：怪兽需为表侧表示且等级≥2，因为等级下降2星要求至少2星。
function c29795530.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 效果①的发动条件判定函数：检查场上是否存在表侧表示且等级≥2的怪兽，存在才可发动。
function c29795530.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测场上是否存在至少1只满足筛选条件的怪兽，用于判断①能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果①的发动处理：使场上所有表侧表示且等级≥2的怪兽等级下降2星，直到回合结束。
function c29795530.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示且等级≥2的怪兽集合，作为下降等级的处理对象。
	local g=Duel.GetMatchingGroup(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部怪兽的等级直到回合结束时下降2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 定义②效果的取对象处理：以场上1只表侧表示且等级≥2的怪兽为对象（实际下降1星）。
function c29795530.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29795530.filter(chkc) end
	-- ②效果发动时，检查场上是否存在至少1只可选为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择对象的提示信息，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只符合条件的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29795530.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的发动处理：将选择的对象怪兽等级下降1星，直到回合结束。
function c29795530.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果处理时当前连锁选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
