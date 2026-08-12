--デストーイ・マーチ
-- 效果：
-- ①：自己场上的「魔玩具」怪兽为对象的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。那之后，以下效果可以适用。
-- ●成为对象的1只「魔玩具」怪兽送去墓地，把1只8星以上的「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽在下次的自己结束阶段除外。
function c74416026.initial_effect(c)
	-- ①：自己场上的「魔玩具」怪兽为对象的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。那之后，以下效果可以适用。●成为对象的1只「魔玩具」怪兽送去墓地，把1只8星以上的「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c74416026.condition)
	e1:SetTarget(c74416026.target)
	e1:SetOperation(c74416026.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的「魔玩具」怪兽
function c74416026.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0xad)
end
-- 发动条件：对方发动了以自己场上的「魔玩具」怪兽为对象的效果，且该发动可以被无效
function c74416026.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c74416026.filter,1,nil,tp)
		-- 检查该连锁的发动是否可以被无效，且该效果是怪兽效果或魔法·陷阱卡的发动
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 效果发动时的目标确认与操作信息设置（无效与破坏）
function c74416026.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤条件：可以送去墓地，且额外卡组存在能以其为素材特殊召唤的8星以上「魔玩具」融合怪兽
function c74416026.tgfilter(c,e,tp)
	-- 检查卡片是否能送去墓地，且额外卡组是否存在满足特殊召唤条件的怪兽
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c74416026.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤条件：额外卡组中可以当作融合召唤特殊召唤的8星以上「魔玩具」融合怪兽
function c74416026.spfilter(c,e,tp,tc)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and c:IsSetCard(0xad)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		-- 检查融合素材是否满足，且在送去墓地的怪兽离场后额外怪兽区域或主要怪兽区域有可用的空位
		and c:CheckFusionMaterial() and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 效果处理：使发动无效并破坏，之后可选择将成为对象的1只「魔玩具」怪兽送去墓地，从额外卡组特殊召唤1只8星以上的「魔玩具」融合怪兽
function c74416026.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象中属于自己场上的「魔玩具」怪兽
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(c74416026.filter,nil,tp)
	-- 如果成功使发动无效，且该卡在场，则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		local tg=g:Filter(Card.IsRelateToEffect,nil,re)
		-- 检查是否存在可送去墓地的对象怪兽，且满足融合素材的限制条件
		if tg:IsExists(c74416026.tgfilter,1,nil,e,tp) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
			-- 询问玩家是否适用后续的特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(74416026,0)) then  --"是否特殊召喚？"
			-- 中断当前效果，使后续处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local tc=tg:FilterSelect(tp,c74416026.tgfilter,1,1,nil,e,tp):GetFirst()
			-- 将选择的怪兽送去墓地，若未成功送去墓地则结束处理
			if Duel.SendtoGrave(tc,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_GRAVE) then return end
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足条件的「魔玩具」融合怪兽
			local sc=Duel.SelectMatchingCard(tp,c74416026.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
			sc:SetMaterial(nil)
			-- 尝试将选择的怪兽以融合召唤的形式表侧表示特殊召唤
			if Duel.SpecialSummonStep(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) then
				local c=e:GetHandler()
				local fid=c:GetFieldID()
				-- 这个效果特殊召唤的怪兽在下次的自己结束阶段除外。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetLabelObject(sc)
				e1:SetCondition(c74416026.rmcon)
				e1:SetOperation(c74416026.rmop)
				-- 检查当前是否已经是自己的结束阶段
				if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
					-- 记录当前回合数和效果ID，以便在下一次自己的结束阶段进行除外处理
					e1:SetLabel(Duel.GetTurnCount(),fid)
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
					sc:RegisterFlagEffect(74416026,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,2,fid)
				else
					e1:SetLabel(0,fid)
					e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
					sc:RegisterFlagEffect(74416026,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1,fid)
				end
				-- 注册用于在结束阶段除外该怪兽的延迟效果
				Duel.RegisterEffect(e1,tp)
				-- 完成特殊召唤的最终处理
				Duel.SpecialSummonComplete()
				sc:CompleteProcedure()
			end
		end
	end
end
-- 延迟除外效果的触发条件：在下一次自己的结束阶段
function c74416026.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local turn,fid=e:GetLabel()
	-- 确认当前是自己的回合、不是特殊召唤的那个回合，且怪兽仍带有正确的标记
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=turn and tc:GetFlagEffectLabel(74416026)==fid
end
-- 延迟除外效果的执行操作：将怪兽除外
function c74416026.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
