--キラーチューン・プレイリスト
-- 效果：
-- 这个卡名的卡在1回合可以发动最多2张。
-- ①：以自己的场上·墓地1只「杀手级调整曲」怪兽为对象才能发动。以下效果各适用。这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
-- ●作为对象的怪兽的自身作为同调素材送去墓地的场合发动的效果适用。
-- ●作为对象的怪兽回到手卡。
local s,id,o=GetID()
-- 定义该卡片的初始效果：创建1个魔法卡发动效果（①），设置其描述、类别为回手牌、发动类型为通常魔法（EFFECT_TYPE_ACTIVATE）、自由时点、1回合最多发动2次（誓约计数）、取对象、提示时点，并指定目标选择函数与效果处理函数后注册到卡片。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合可以发动最多2张。①：以自己的场上·墓地1只「杀手级调整曲」怪兽为对象才能发动。以下效果各适用。这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(2,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的卡：必须是自己的场上·墓地的「杀手级调整曲」怪兽；若没有‘作为同调素材送去墓地时发动的效果’，则需要能回手牌；若有该效果，则能回手牌或该效果能指定其为对象即可。
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsFaceupEx() and c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER)) then return false end
	local te=c.killer_tune_be_material_effect
	if not te then return c:IsAbleToHand() end
	local tg=te:GetTarget()
	return c:IsAbleToHand() or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 目标选择处理：先检查存在合法对象；从自己场上·墓地选择1只符合条件的「杀手级调整曲」怪兽作为对象，清除默认目标后手动建立该卡与效果的关联并保存为标签；若该对象有‘作为同调素材送去墓地时发动的效果’，则调用其目标检查函数确认可发动；最后清除旧操作信息并设置回手牌的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local cc=e:GetLabelObject()
		if cc and cc.killer_tune_be_material_effect then
			local ce=cc.killer_tune_be_material_effect
			local tg=ce:GetTarget()
			return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
		else
			return chkc:IsFaceupEx() and chkc:IsControler(tp) and chkc:IsSetCard(0x1d5) and chkc:IsType(TYPE_MONSTER) and chkc:IsAbleToHand()
		end
	end
	-- 发动条件判断：自己场上·墓地是否存在至少1只满足s.filter条件的「杀手级调整曲」怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 向玩家显示选择对象的提示信息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己的场上·墓地选择1只满足s.filter条件的「杀手级调整曲」怪兽，并自动将其登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	-- 清除刚才Duel.SelectTarget自动登记的对象，以便后续手动建立对象关联和设置标签对象。
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te=tc.killer_tune_be_material_effect
	if te then
		local tg=te:GetTarget()
		if tg then
			local cchk=e:IsCostChecked()
			e:SetCostCheck(false)
			tg(e,tp,eg,ep,ev,re,r,rp,1)
			e:SetCostCheck(cchk)
		end
	end
	-- 清除当前连锁的操作信息，避免之前调用其他效果的目标检查函数时写入的信息残留影响本次效果。
	Duel.ClearOperationInfo(0)
	-- 设置本次效果的操作信息：效果分类为回手牌，涉及对象为已选择的1张卡，供其他卡片正确响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：若对象卡仍与连锁相关，先适用其‘作为同调素材送去墓地时发动的效果’（若有）；在对象不受王家长眠之谷影响时，中断处理并将该卡加入手牌；随后给自己适用‘直到回合结束时不是调整不能特殊召唤’的限制。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToChain() then
		local te=tc.killer_tune_be_material_effect
		if te then
			local op=te:GetOperation()
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
		-- 判断对象卡是否不受‘王家长眠之谷’等禁止从墓地离开的效果限制，只有不受限制时才执行回手牌。
		if aux.NecroValleyFilter()(tc) then
			-- 中断当前效果处理，使随后的回手牌处理与之前的同调素材效果不在同一时点处理，避免时点冲突。
			Duel.BreakEffect()
			-- 将对象怪兽送回持有者手卡，移动原因记为效果。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将上述自肃效果注册给当前玩家（作用于玩家自身），持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤限制判定：若被特殊召唤的怪兽的原本种类不包含调整，则禁止该特殊召唤，即只能特殊召唤调整怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
