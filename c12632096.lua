--超銀河眼の光波龍
-- 效果：
-- 9星怪兽×3
-- ①：这张卡有「光波」卡在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡最多3个超量素材取除才能发动。选取除数量的对方场上的表侧表示怪兽，那些控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，攻击力变成4500，卡名当作「超银河眼光波龙」使用。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
function c12632096.initial_effect(c)
	-- 为这张卡添加“9星怪兽×3”的XYZ召唤手续（用等级9的怪兽3只叠放）。
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：这张卡有「光波」卡在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡最多3个超量素材取除才能发动。选取除数量的对方场上的表侧表示怪兽，那些控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，攻击力变成4500，卡名当作「超银河眼光波龙」使用。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
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
-- 效果发动条件：这张卡的超量素材中存在至少1张「光波」卡。
function c12632096.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xe5)
end
-- 选择对象的过滤条件：对方场上的表侧表示怪兽，且未受到“不能改变控制权”效果影响。
function c12632096.ctfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 效果发动代价：从这张卡上取除超量素材，数量为计算出的rt张（至少1张）；实际取除后将数量记录到e的标签中。
function c12632096.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 计算本次可取除素材数量：取满足条件的对方表侧表示怪兽数、己方可用怪兽区空格数和3这三者的最小值。
	local rt=math.min(Duel.GetMatchingGroupCount(c12632096.ctfilter,tp,0,LOCATION_MZONE,nil),(Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)),3)
	if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
-- 效果目标阶段：只要满足发动条件即可发动，并设置操作信息为改变控制权（对象与数量在效果处理时确定）。
function c12632096.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：本连锁包含改变控制权效果，处理对象与数量暂不确定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 效果处理：先给己方场上这张卡以外的怪兽附加结束阶段前不能直接攻击的限制；然后选取与取除素材数相同数量的对方表侧表示怪兽，获得其控制权直到结束阶段；再对这些怪兽逐一无效化其效果、攻击力变成4500、卡名当作「超银河眼光波龙」。
function c12632096.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选取除数量的对方场上的表侧表示怪兽，那些控制权直到结束阶段得到。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c12632096.atktg)
	e1:SetLabel(c:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“这张卡以外的自己怪兽不能直接攻击”的负面效果注册到场上，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 计算实际选择变更控制权的怪兽数：取本次取除素材数与己方可用怪兽区空格数的较小值，防止无空格放置。
	local ct=math.min(e:GetLabel(),(Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)))
	-- 向玩家显示“请选择要改变控制权的怪兽”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择ct张满足条件的表侧表示怪兽作为改变控制权对象。
	local g=Duel.SelectMatchingCard(tp,c12632096.ctfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
	-- 显示所选怪兽的选中动画，并将其记录为本连锁的对象。
	Duel.HintSelection(g)
	-- 将所选怪兽的控制权转移给己方，持续到结束阶段。
	Duel.GetControl(g,tp,PHASE_END,1)
	-- 获取刚才控制权变更操作实际成功的怪兽组，用于后续对它们施加效果。
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	while tc do
		-- 使与这些怪兽关联的连锁效果无效化，并在怪兽变里侧时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 这个效果得到控制权的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		-- 这个效果得到控制权的怪兽的效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3,true)
		-- 攻击力变成4500
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(4500)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4,true)
		-- 卡名当作「超银河眼光波龙」使用
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CHANGE_CODE)
		e5:SetValue(12632096)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e5,true)
		tc=og:GetNext()
	end
end
-- 判定不能直接攻击的对象：除发动本效果的这张卡（通过field id标记）以外的己方怪兽均受到不能直接攻击限制。
function c12632096.atktg(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
