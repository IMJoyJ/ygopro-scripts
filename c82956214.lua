--ドラグマ・パニッシュメント
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只怪兽从额外卡组送去墓地，作为对象的怪兽破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
function c82956214.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只怪兽从额外卡组送去墓地，作为对象的怪兽破坏。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,82956214+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c82956214.target)
	e1:SetOperation(c82956214.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上可作为破坏对象的表侧表示怪兽（额外卡组中必须存在攻击力大于或等于该怪兽攻击力且能送去墓地的怪兽）
function c82956214.desfilter(c,tp)
	-- 检查怪兽是否表侧表示，且额外卡组中是否存在至少1张攻击力大于或等于该怪兽攻击力且能送去墓地的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c82956214.tgfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttack())
end
-- 过滤额外卡组中攻击力大于或等于指定数值且能送去墓地的怪兽
function c82956214.tgfilter(c,atk)
	return c:IsAttackAbove(atk) and c:IsAbleToGrave()
end
-- 效果发动的目标选择与检测函数
function c82956214.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c82956214.desfilter(chkc,tp) end
	-- 检查对方场上是否存在符合条件的表侧表示怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c82956214.desfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只符合条件的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c82956214.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息：从额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息：破坏选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（发动）函数
function c82956214.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从额外卡组选择1只攻击力在对象怪兽以上的怪兽
		local g=Duel.SelectMatchingCard(tp,c82956214.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,atk)
		local gc=g:GetFirst()
		-- 若成功将选中的额外卡组怪兽送去墓地
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) then
			-- 破坏作为对象的怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c82956214.splimit)
		-- 判断当前是否为自己的回合，以确定限制效果的持续时间
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 给玩家注册该限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤来自额外卡组的怪兽
function c82956214.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
