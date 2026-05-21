--烙印の裁き
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只8星以上的融合怪兽为对象才能发动。持有那只怪兽的攻击力以上的攻击力的对方场上的怪兽全部破坏。
-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
function c93595154.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「阿不思的落胤」的卡名
	aux.AddCodeList(c,68468459)
	-- ①：以自己场上1只8星以上的融合怪兽为对象才能发动。持有那只怪兽的攻击力以上的攻击力的对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93595154,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c93595154.target)
	e1:SetOperation(c93595154.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c93595154.regcon)
	e2:SetOperation(c93595154.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡为让「阿不思的落胤」的效果发动而被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93595154,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,93595154)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCondition(c93595154.setcon)
	e3:SetTarget(c93595154.settg)
	e3:SetOperation(c93595154.setop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的、8星以上的融合怪兽，且对方场上存在持有该怪兽攻击力以上的攻击力的怪兽
function c93595154.filter(c,tp)
	-- 检查卡片是否为表侧表示、融合怪兽、等级8以上，且对方场上存在攻击力大于等于该怪兽攻击力的怪兽
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and Duel.IsExistingMatchingCard(c93595154.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤对方场上表侧表示且攻击力在指定数值以上的怪兽
function c93595154.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- ①号效果的发动准备与靶向函数，处理取对象判定和破坏信息的注册
function c93595154.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c93595154.filter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的、可作为效果对象的8星以上融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c93595154.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只符合条件的8星以上融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93595154.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取对方场上所有攻击力在所选怪兽攻击力以上的怪兽组
	local dg=Duel.GetMatchingGroup(c93595154.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 设置当前连锁的操作信息为破坏这些对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- ①号效果的实际执行函数，破坏符合条件的对方怪兽
function c93595154.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的自己场上的融合怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取对方场上持有该融合怪兽攻击力以上的攻击力的怪兽组
		local g=Duel.GetMatchingGroup(c93595154.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 因效果破坏这些符合条件的对方怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 检查这张卡是否是作为「阿不思的落胤」效果发动的Cost而被送去墓地
function c93595154.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该送墓事件的连锁卡片密码
	local code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated() and (code1==68468459 or code2==68468459)
end
-- 在送去墓地的这张卡上注册一个在回合结束前有效的标记，用于记录其满足了盖放条件
function c93595154.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(93595154,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②号效果的发动条件函数，检查是否在结束阶段且本回合已注册满足条件的标记
function c93595154.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否带有本回合因「阿不思的落胤」送墓的标记，且当前处于结束阶段
	return e:GetHandler():GetFlagEffect(93595154)>0 and Duel.GetCurrentPhase()&PHASE_END~=0
end
-- ②号效果的发动准备函数，检查自身是否可以盖放并注册离墓操作信息
function c93595154.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置当前连锁的操作信息为将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的实际执行函数，将这张卡在自己场上盖放
function c93595154.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
