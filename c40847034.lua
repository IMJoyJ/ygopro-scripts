--キラーチューン・プレイリスト
-- 效果：
-- 这个卡名的卡在1回合可以发动最多2张。
-- ①：以自己的场上·墓地1只「杀手级调整曲」怪兽为对象才能发动。以下效果各适用。这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
-- ●作为对象的怪兽的自身作为同调素材送去墓地的场合发动的效果适用。
-- ●作为对象的怪兽回到手卡。
local s,id,o=GetID()
-- 创建并注册主效果，设置为自由连锁发动，最多发动2次，需要选择对象，发动时提示
function s.initial_effect(c)
	-- ①：以自己的场上·墓地1只「杀手级调整曲」怪兽为对象才能发动。以下效果各适用。这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
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
-- 过滤函数，用于判断目标怪兽是否满足效果发动条件，包括是否为调整曲怪兽、是否能回手或是否能作为同调素材发动效果
function s.filter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsFaceupEx() and c:IsSetCard(0x1d5) and c:IsType(TYPE_MONSTER)) then return false end
	local te=c.killer_tune_be_material_effect
	if not te then return c:IsAbleToHand() end
	local tg=te:GetTarget()
	return c:IsAbleToHand() or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 选择目标函数，检查是否有满足条件的怪兽作为对象，设置操作信息为回手
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
	-- 判断是否满足发动条件，即场上或墓地是否存在符合条件的「杀手级调整曲」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 向玩家提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的「杀手级调整曲」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	-- 清除当前连锁中的目标卡
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
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
	-- 设置操作信息，表示将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，根据对象怪兽是否具有特殊效果来决定是否发动该效果，并处理回手效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToChain() then
		local te=tc.killer_tune_be_material_effect
		if te then
			local op=te:GetOperation()
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
		-- 判断对象怪兽是否受王家长眠之谷影响
		if aux.NecroValleyFilter()(tc) then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将对象怪兽送回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后，直到回合结束时自己不是调整不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能特殊召唤调整的永续效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤的怪兽类型为非调整
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
