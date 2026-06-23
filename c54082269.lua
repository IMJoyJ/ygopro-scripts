--BF－フルアーマード・ウィング
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：只要这张卡在怪兽区域存在，每次对方场上的怪兽把效果发动，给那只对方的表侧表示怪兽放置1个楔指示物（最多1个）。
-- ③：1回合1次，以对方场上1只有楔指示物放置的怪兽为对象才能发动。得到那只怪兽的控制权。
-- ④：自己结束阶段才能发动。有楔指示物放置的怪兽全部破坏。
function c54082269.initial_effect(c)
	-- 设置同调召唤手续：「黑羽」调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c54082269.efilter)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方场上的怪兽把效果发动，给那只对方的表侧表示怪兽放置1个楔指示物（最多1个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 设置操作为在连锁发生时记录这张卡在场上存在。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，每次对方场上的怪兽把效果发动，给那只对方的表侧表示怪兽放置1个楔指示物（最多1个）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c54082269.acop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，以对方场上1只有楔指示物放置的怪兽为对象才能发动。得到那只怪兽的控制权。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54082269,0))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c54082269.cttg)
	e4:SetOperation(c54082269.ctop)
	c:RegisterEffect(e4)
	-- ④：自己结束阶段才能发动。有楔指示物放置的怪兽全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(54082269,1))
	e5:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCondition(c54082269.descon)
	e5:SetTarget(c54082269.destg)
	e5:SetOperation(c54082269.desop)
	c:RegisterEffect(e5)
end
-- 免疫效果过滤器：判定效果来源是否为其他卡的效果。
function c54082269.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 放置楔指示物的效果处理：在对方场上怪兽发动效果的连锁处理完毕时，给该怪兽放置1个楔指示物。
function c54082269.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) or tc:IsFacedown() or tc:GetCounter(0x1002)>0 then return end
	-- 获取发动该效果的玩家以及发动时的位置。
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	if p~=tp and loc==LOCATION_MZONE and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		tc:AddCounter(0x1002,1)
	end
end
-- 过滤条件：有楔指示物放置且可以改变控制权的怪兽。
function c54082269.ctfilter(c)
	return c:GetCounter(0x1002)>0 and c:IsControlerCanBeChanged()
end
-- 得到控制权效果的发动准备与目标选择。
function c54082269.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54082269.ctfilter(chkc) end
	-- 步骤0：检查对方场上是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c54082269.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足过滤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c54082269.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为：改变1只怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 得到控制权效果的执行：获取对象怪兽的控制权。
function c54082269.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让玩家tp获得目标怪兽的控制权。
		Duel.GetControl(tc,tp)
	end
end
-- 破坏效果的发动条件：当前回合是自己的回合。
function c54082269.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：有楔指示物放置的怪兽。
function c54082269.desfilter(c)
	return c:GetCounter(0x1002)>0
end
-- 破坏效果的发动准备与目标确认。
function c54082269.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查场上是否存在至少1只放置了楔指示物的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有放置了楔指示物的怪兽。
	local g=Duel.GetMatchingGroup(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息为：破坏所有放置了楔指示物的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行：将场上所有放置了楔指示物的怪兽破坏。
function c54082269.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有放置了楔指示物的怪兽。
	local g=Duel.GetMatchingGroup(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏目标怪兽组。
	Duel.Destroy(g,REASON_EFFECT)
end
