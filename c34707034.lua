--アビスコール
-- 效果：
-- 选择自己墓地3只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽效果无效化，不能攻击宣言，结束阶段时破坏。
function c34707034.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，可以特殊召唤怪兽，具有取对象效果，触发时点为自由时点，提示在结束阶段时点
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c34707034.target)
	e1:SetOperation(c34707034.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选名字带有「水精鳞」且可以特殊召唤的怪兽
function c34707034.filter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标选择函数，判断是否满足特殊召唤条件，包括未被青眼精灵龙效果影响、场上空位足够、墓地存在3只符合条件的怪兽
function c34707034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c34707034.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检测玩家墓地是否存在3只符合条件的怪兽
		and Duel.IsExistingTarget(c34707034.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择3只符合条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c34707034.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽数量为3
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,3,0,0)
end
-- 效果处理函数，处理特殊召唤及后续效果
function c34707034.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	-- 检测玩家场上是否有足够的怪兽区域来特殊召唤所有目标怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 使特殊召唤的怪兽不能攻击宣言
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使特殊召唤的怪兽在结束阶段时被破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(34707034,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=g:GetNext()
	end
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 注册一个在结束阶段时触发的持续效果，用于破坏特殊召唤的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c34707034.descon)
	e1:SetOperation(c34707034.desop)
	-- 将结束阶段破坏效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 破坏过滤函数，用于筛选具有特定标记的怪兽
function c34707034.desfilter(c,fid)
	return c:GetFlagEffectLabel(34707034)==fid
end
-- 破坏效果的触发条件函数，判断是否还有符合条件的怪兽需要被破坏
function c34707034.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c34707034.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将符合条件的怪兽破坏
function c34707034.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c34707034.desfilter,nil,e:GetLabel())
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
