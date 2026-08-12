--超銀河眼の光波龍
-- 效果：
-- 9星怪兽×3
-- ①：这张卡有「光波」卡在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡最多3个超量素材取除才能发动。选取除数量的对方场上的表侧表示怪兽，那些控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，攻击力变成4500，卡名当作「超银河眼光波龙」使用。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
function c12632096.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为9且数量为3的怪兽作为超量素材
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ●1回合1次，把这张卡最多3个超量素材取除才能发动。选取除数量的对方场上的表侧表示怪兽，那些控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，攻击力变成4500，卡名当作「超银河眼光波龙」使用。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(12632096,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12632096.ctcon)
	e1:SetCost(c12632096.ctcost)
	e1:SetTarget(c12632096.cttg)
	e1:SetOperation(c12632096.ctop)
	c:RegisterEffect(e1)
end
-- 判断此卡的超量素材中是否存在「光波」卡
function c12632096.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xe5)
end
-- 筛选对方场上的表侧表示且可以改变控制权的怪兽
function c12632096.ctfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 支付效果代价，移除1~3个超量素材
function c12632096.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 计算可选择的对方怪兽数量，最多为3个
	local rt=math.min(Duel.GetMatchingGroupCount(c12632096.ctfilter,tp,0,LOCATION_MZONE,nil),(Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)),3)
	if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 设置效果目标，准备选择对方怪兽
function c12632096.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 处理效果的发动与执行
function c12632096.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置自己场上的怪兽不能直接攻击的效果，直到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c12632096.atktg)
	e1:SetLabel(c:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
	-- 计算实际可选择的怪兽数量
	local ct=math.min(e:GetLabel(),(Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)))
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	-- 选择满足条件的对方怪兽
	local g=Duel.SelectMatchingCard(tp,c12632096.ctfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 显示被选中的怪兽
	Duel.HintSelection(g)
	-- 将选中的怪兽的控制权转移给玩家，持续到结束阶段
	Duel.GetControl(g,tp,PHASE_END,1)
	-- 获取实际操作的怪兽组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		-- 使目标怪兽的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3,true)
		-- 将目标怪兽的攻击力设置为4500
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(4500)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4,true)
		-- 将目标怪兽的卡名变为「超银河眼光波龙」
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_CODE)
		e5:SetValue(12632096)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5,true)
		tc=og:GetNext()
	end
end
-- 判断目标怪兽是否为本卡
function c12632096.atktg(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
