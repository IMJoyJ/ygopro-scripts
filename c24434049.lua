--エピュアリィ・プランプ
-- 效果：
-- 2星怪兽×2
-- ①：1回合1次，以自己或者对方的墓地的魔法·陷阱卡合计最多2张为对象才能发动。那些卡在这张卡下面重叠作为超量素材。这张卡有「纯爱妖精美味回忆」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选场上1只怪兽直到结束阶段除外。这个效果1回合可以使用最多3次。
local s,id,o=GetID()
-- 初始化并注册此卡全部效果：①从双方墓地选最多2张魔法·陷阱卡作为超量素材叠放；若持有「纯爱妖精美味回忆」素材则可在对方回合发动，否则仅限自己回合起动；②自己发动「纯爱妖精」速攻魔法时将其叠放，并可选择场上1只怪兽除外直到结束阶段。
function s.initial_effect(c)
	-- 向卡组名单中登记「纯爱妖精美味回忆」（55584558），使本卡被视为记载了该卡名，用于相关卡名检索与特殊召唤等判定。
	aux.AddCodeList(c,55584558)
	-- 为此卡设置超量召唤手续：2星怪兽×2只重叠作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 效果①对应原文：①：1回合1次，以自己或者对方的墓地的魔法·陷阱卡合计最多2张为对象才能发动。那些卡在这张卡下面重叠作为超量素材。这张卡有「纯爱妖精美味回忆」在作为超量素材的场合，这个效果在对方回合也能发动。
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
	-- 效果②对应原文：②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选场上1只怪兽直到结束阶段除外。这个效果1回合可以使用最多3次。
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
-- 效果①（快速效果版）的发动条件：此卡的超量素材中存在「纯爱妖精美味回忆」，此时才允许在对方回合作为诱发即时效果发动。
function s.gmatcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,55584558)
end
-- 效果①（起动效果版）的发动条件：此卡的超量素材中不存在「纯爱妖精美味回忆」，只能在自己主要阶段作为起动效果发动。
function s.gmatcon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,55584558)
end
-- 效果①选择对象的筛选条件：所选卡必须是魔法·陷阱卡且能够作为超量素材使用。
function s.gmattgfilter(c,sc)
	return c:IsCanOverlay() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动处理：确认场上有合法对象；向对方提示本效果发动；让操作者从双方墓地选择1～2张符合条件的魔法·陷阱卡作为对象；并设置连锁信息为这些卡将离开墓地。
function s.gmattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 发动合法性检查：存在至少1张可从墓地选择为对象的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.gmattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c) end
	-- 向对方玩家提示本效果的发动，显示效果描述，使对方知晓我方发动了哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 为操作者显示选择提示「请选择要作为超量素材的卡」，供选择交互使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让操作者从双方墓地选择1～2张满足条件的魔法·陷阱卡，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.gmattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil,c)
	-- 设置操作信息：这些对象卡将因效果离开墓地（成为超量素材），类别为CATEGORY_LEAVE_GRAVE，数量为选择张数，用于触发相关场合。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- 效果处理时对对象卡的过滤：不能是免疫此效果的卡，且必须仍可作为超量素材。
function s.gmafilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- 效果①处理：取得仍与连锁相关的对象卡并过滤后，若此卡仍在场上且与连锁相关，则将那些卡叠放为此卡的超量素材。
function s.gmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与本连锁相关的所有目标卡，并过滤掉免疫此效果或不能叠放的卡。
	local g=Duel.GetTargetsRelateToChain():Filter(s.gmafilter,nil,e)
	if c:IsRelateToChain() and #g>0 then
		-- 将过滤后的卡组叠放在此卡下面作为超量素材。
		Duel.Overlay(c,g)
	end
end
-- 效果②的发动条件：连锁中发动的是「纯爱妖精」速攻魔法卡，且发动者为这张卡的控制者自己。
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c)
end
-- 效果②的发动时目标确认：检查那张速攻魔法卡能否作为超量素材；向对方提示发动；并让该卡与本效果建立联系，便于后续处理。
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 向对方玩家提示本效果的发动，显示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- 效果②处理：若此卡与那张速攻魔法卡均仍与连锁相关且可叠放，则先将那张速攻魔法卡从魔法陷阱区域转移并叠放；然后可选场上1只怪兽，以暂时除外方式除外，并在结束阶段将其返回。
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsCanOverlay() and not tc:IsImmuneToEffect(e) then
		tc:CancelToGrave()
		-- 将发动的速攻魔法卡叠放在此卡下面作为超量素材。
		Duel.Overlay(c,tc)
		-- 检查场上是否存在至少1只可以被除外的怪兽，作为「可以除外怪兽」选择的前提。
		if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
			-- 询问操作者是否选择除外怪兽，若选择否则跳过后续除外处理。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选怪兽除外？"
			-- 断开效果处理，使后续的除外处理与前面的叠放处理时机分开，避免误用时点。
			Duel.BreakEffect()
			-- 为操作者显示选择提示「请选择要除外的卡」，供选择交互使用。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			-- 让操作者从双方场上选择1只可以被除外的怪兽。
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
			local rc=tg:GetFirst()
			-- 将被选择的怪兽以效果原因且REASON_TEMPORARY暂时除外；若成功则设置返回标志，准备在结束阶段返回。
			if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- 对应原文“那之后，可以选场上1只怪兽直到结束阶段除外。”：为被暂时除外的怪兽注册结束阶段返回的处理效果，使其在结束阶段回到场上。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(rc)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				-- 将上述“结束阶段返回”的持续效果注册到场上，由控制者tp负责维持，实现被除外怪兽在结束阶段的回归。
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
-- 返回效果的发动条件：被除外的怪兽身上仍带有本效果设置的返回标记（即没有因其他原因重置）时，才在结束阶段执行返回。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 返回效果的操作：将暂时除外的怪兽返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 强制把被暂时除外的怪兽返回场上，以离场前的表示形式归还。
	Duel.ReturnToField(e:GetLabelObject())
end
