--エピュアリィ・プランプ
-- 效果：
-- 2星怪兽×2
-- ①：1回合1次，以自己或者对方的墓地的魔法·陷阱卡合计最多2张为对象才能发动。那些卡在这张卡下面重叠作为超量素材。这张卡有「纯爱妖精美味回忆」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选场上1只怪兽直到结束阶段除外。这个效果1回合可以使用最多3次。
local s,id,o=GetID()
-- 初始化效果函数，注册XYZ召唤手续和三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「纯爱妖精美味回忆」的卡名
	aux.AddCodeList(c,55584558)
	-- 添加XYZ召唤手续，需要2星怪兽2只作为素材
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己或者对方的墓地的魔法·陷阱卡合计最多2张为对象才能发动。那些卡在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从墓地补充超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.gmatcon)
	e1:SetTarget(s.gmattg)
	e1:SetOperation(s.gmatop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCondition(s.gmatcon2)
	c:RegisterEffect(e2)
	-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选场上1只怪兽直到结束阶段除外。这个效果1回合可以使用最多3次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动的速攻魔法卡在这张卡下面重叠"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：该卡的叠放区有「纯爱妖精美味回忆」
function s.gmatcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,55584558)
end
-- 效果②的发动条件：该卡的叠放区没有「纯爱妖精美味回忆」
function s.gmatcon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,55584558)
end
-- 过滤函数，用于选择可作为超量素材的魔法·陷阱卡
function s.gmattgfilter(c,sc)
	return c:IsCanOverlay() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动时选择目标，选择1~2张墓地的魔法·陷阱卡
function s.gmattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查是否有满足条件的墓地魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.gmattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c) end
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择1~2张墓地的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,s.gmattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil,c)
	-- 设置效果操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- 过滤函数，用于判断卡是否可以作为超量素材
function s.gmafilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- 效果①的处理函数，将选中的卡叠放至该卡下
function s.gmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与连锁相关的选中卡，并过滤出可叠放的卡
	local g=Duel.GetTargetsRelateToChain():Filter(s.gmafilter,nil,e)
	if c:IsRelateToChain() and #g>0 then
		-- 将卡叠放至该卡下
		Duel.Overlay(c,g)
	end
end
-- 效果②的发动条件：对方发动速攻魔法卡且为「纯爱妖精」系列
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c)
end
-- 效果②的发动时选择目标，确认该卡可叠放
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 提示对方玩家该效果已被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- 效果②的处理函数，将发动的速攻魔法卡叠放至该卡下，并可选择除外一只怪兽
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsCanOverlay() and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		-- 将发动的速攻魔法卡叠放至该卡下
		Duel.Overlay(c,tc)
		-- 检查场上是否存在可除外的怪兽
		if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
			-- 询问玩家是否选择除外一只怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选怪兽除外？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 选择场上一只可除外的怪兽
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
			local rc=tg:GetFirst()
			-- 将选中的怪兽除外
			if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- 注册一个结束阶段时将怪兽返回场上的持续效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(rc)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				-- 将该效果注册到玩家全局环境
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 判断该怪兽是否在结束阶段返回场上的条件
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 将怪兽返回场上的处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
