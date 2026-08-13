--ワーニングポイント
-- 效果：
-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。这个回合，那些表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
function c11429811.initial_effect(c)
	-- ①：怪兽召唤·反转召唤·特殊召唤时才能发动。这个回合，那些表侧表示怪兽不能攻击，效果无效化，不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c11429811.target)
	e1:SetOperation(c11429811.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 发动时确认召唤成功的那组怪兽中是否存在表侧表示怪兽；若存在，则将其中所有表侧表示怪兽设为本卡的对象，并登记将对这些怪兽适用无效系效果的操作信息。
function c11429811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(Card.IsFaceup,1,nil) end
	local g=eg:Filter(Card.IsFaceup,nil)
	-- 将召唤成功的那组怪兽中的表侧表示怪兽全部设为当前连锁的对象，以便效果处理时按对象获取并处理。
	Duel.SetTargetCard(g)
	-- 登记操作信息：本连锁要对那些表侧表示怪兽适用CATEGORY_DISABLE（效果无效化）处理，目标数量为g中的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理时，从连锁信息中取出对象怪兽，并过滤出仍与效果相关且表侧表示的怪兽，对每只怪赋予不能攻击、效果无效化、不能作为融合/同调/超量/连接素材的效果；若本卡未被无效，还会将其相关连锁无效化并追加效果无效化处理。
function c11429811.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时记录的对象卡组，过滤掉已与此效果失去关联或已离场的卡，再保留表侧表示怪兽作为实际处理对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsFaceup,nil)
	local tc=g:GetFirst()
	while tc do
		-- 这个回合，那些表侧表示怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not c:IsDisabled() then
			-- 把与这些怪兽相关的连锁（如召唤成功时发动的效果）无效化，直至其变为里侧表示（用于实现“效果无效化”）。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果无效化：让那些表侧表示怪兽的卡本身处于无效状态。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 效果无效化：让那些表侧表示怪兽的效果无效化，并在变里侧表示时重置。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		-- 不能作为融合·同调·超量·连接召唤的素材（此处为不能作为同调素材）。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e4:SetRange(LOCATION_MZONE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetValue(1)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e5:SetValue(c11429811.fuslimit)
		tc:RegisterEffect(e5)
		local e6=e4:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e6)
		local e7=e4:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e7)
		tc=g:GetNext()
	end
end
-- 融合素材限制函数：仅当召唤类型为融合召唤时允许作为融合素材，从而使该怪兽不能作为融合召唤的素材。
function c11429811.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
