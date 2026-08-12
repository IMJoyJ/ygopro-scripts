--BF－フルアーマード・ウィング
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽1只以上
-- ①：场上的这张卡不受其他卡的效果影响。
-- ②：只要这张卡在怪兽区域存在，每次对方场上的怪兽把效果发动，给那只对方的表侧表示怪兽放置1个楔指示物（最多1个）。
-- ③：1回合1次，以对方场上1只有楔指示物放置的怪兽为对象才能发动。得到那只怪兽的控制权。
-- ④：自己结束阶段才能发动。有楔指示物放置的怪兽全部破坏。
function c54082269.initial_effect(c)
	-- 为这张卡添加同调召唤手续：以1只「黑羽」怪兽为调整、调整以外的怪兽1只以上为非调整素材
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
	-- ②：只要这张卡在怪兽区域存在，每次对方场上的怪兽把效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在怪兽区域存在（设置连锁标志，供后续指示物处理确认时点时这张卡在场）
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：给那只对方的表侧表示怪兽放置1个楔指示物（最多1个）。
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
c54082269.mentioned_counter={
	[0x1002]=true,
}
-- 效果免疫的过滤函数：只免疫持有者不是这张卡持有者的效果，即不受其他卡的效果影响
function c54082269.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 连锁处理结束时触发：若发动效果的是对方怪兽区域的表侧表示怪兽、尚未放置楔指示物且这张卡在连锁发生时在场，则给那只怪兽放置1个楔指示物
function c54082269.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) or tc:IsFacedown() or tc:GetCounter(0x1002)>0 then return end
	-- 取得该连锁的发动玩家和发动位置，用于判断是否为对方场上怪兽发动的效果
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	if p~=tp and loc==LOCATION_MZONE and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		tc:AddCounter(0x1002,1)
	end
end
-- 改变控制权效果的对象过滤函数：放置有楔指示物且控制权可以被改变的怪兽
function c54082269.ctfilter(c)
	return c:GetCounter(0x1002)>0 and c:IsControlerCanBeChanged()
end
-- ③效果的对象选择处理：确认对方场上存在可取为对象的有楔指示物的怪兽，提示并选择其中1只，并设置改变控制权的操作信息
function c54082269.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c54082269.ctfilter(chkc) end
	-- 发动条件检查：对方场上必须存在至少1只可以取为对象的有楔指示物且控制权可改变的怪兽
	if chk==0 then return Duel.IsExistingTarget(c54082269.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示消息「请选择要改变控制权的怪兽」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让对方场上1只有楔指示物放置的怪兽成为这个效果的对象
	local g=Duel.SelectTarget(tp,c54082269.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为改变控制权，对象是选择的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ③效果的处理：若对象怪兽仍与这个效果相关联，则自己得到那只怪兽的控制权
function c54082269.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即被选择的那只有楔指示物的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到那只怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
-- ④效果的发动条件：只有自己的结束阶段才能发动
function c54082269.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（即是否为自己的结束阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 破坏效果的过滤函数：放置有楔指示物的怪兽
function c54082269.desfilter(c)
	return c:GetCounter(0x1002)>0
end
-- ④效果的目标处理：确认场上存在有楔指示物放置的怪兽，取得全部这类怪兽并设置破坏的操作信息
function c54082269.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方怪兽区域必须存在至少1只有楔指示物放置的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上全部有楔指示物放置的怪兽
	local g=Duel.GetMatchingGroup(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为破坏，对象是全部有楔指示物放置的怪兽，数量为这组卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ④效果的处理：将双方场上有楔指示物放置的怪兽全部以效果破坏
function c54082269.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新取得双方场上全部有楔指示物放置的怪兽（效果处理时确定）
	local g=Duel.GetMatchingGroup(c54082269.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因破坏这组怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
