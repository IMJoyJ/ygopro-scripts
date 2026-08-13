--アビスコール
-- 效果：
-- 选择自己墓地3只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽效果无效化，不能攻击宣言，结束阶段时破坏。
function c34707034.initial_effect(c)
	-- 选择自己墓地3只名字带有「水精鳞」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽效果无效化，不能攻击宣言，结束阶段时破坏。
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
-- 过滤函数：判断卡是否名字带有「水精鳞」且能够被表侧守备表示特殊召唤。
function c34707034.filter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动条件与目标选择：检测青眼精灵龙限制、主要怪兽区空位，并选择墓地3只满足条件的「水精鳞」怪兽作为对象。
function c34707034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c34707034.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区的可用空格数大于2，确保能特殊召唤3只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查墓地是否存在至少3只满足筛选条件的「水精鳞」怪兽可供选择。
		and Duel.IsExistingTarget(c34707034.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 向当前玩家发送选择卡片提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择3只满足条件的「水精鳞」怪兽，并登记为这张卡发动时的对象。
	local g=Duel.SelectTarget(tp,c34707034.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤3只对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,3,0,0)
end
-- 效果处理：将选择的对象怪兽依次以表侧守备表示特殊召唤，并附加效果无效化、不能攻击宣言、结束阶段破坏的处理。
function c34707034.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出连锁处理中的对象卡组，并筛选出仍与这张卡效果有关联的怪兽，防止对象已离场导致无效。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	-- 再次确认自己主要怪兽区的可用格数足够容纳要特殊召唤的怪兽，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 将当前怪兽以表侧守备表示特殊召唤（逐只处理，用于后续附加状态）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(34707034,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=g:GetNext()
	end
	-- 完成特殊召唤处理，使此前通过 SpecialSummonStep 累积的怪兽正式特殊召唤成功。
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 结束阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c34707034.descon)
	e1:SetOperation(c34707034.desop)
	-- 将结束阶段破坏的诱发效果注册到场上，属于当前玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否带有本次发动所赋予的 fid 标记，用于识别本次特殊召唤的怪兽。
function c34707034.desfilter(c,fid)
	return c:GetFlagEffectLabel(34707034)==fid
end
-- 结束阶段破坏效果的发动条件：若本次特殊召唤的怪兽仍有残留在场上则满足条件，否则清理标记并重置该效果。
function c34707034.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c34707034.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏处理：筛选出本次特殊召唤且带有对应标记的怪兽。
function c34707034.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c34707034.desfilter,nil,e:GetLabel())
	-- 将这些本次特殊召唤的怪兽以效果原因破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
