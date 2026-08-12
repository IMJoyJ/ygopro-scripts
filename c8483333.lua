--モザイク・マンティコア
-- 效果：
-- ①：这张卡上级召唤成功的场合，下次的自己回合的准备阶段发动。为这张卡的上级召唤而解放的怪兽从墓地尽可能往自己场上特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化。
function c8483333.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，下次的自己回合的准备阶段发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c8483333.regcon)
	e1:SetOperation(c8483333.regop)
	c:RegisterEffect(e1)
end
-- 检测这张卡是否为上级召唤成功
function c8483333.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 在上级召唤成功时，注册一个在下次自己回合准备阶段发动的阶段效果
function c8483333.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为这张卡的上级召唤而解放的怪兽从墓地尽可能往自己场上特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8483333,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCondition(c8483333.spcon)
	e1:SetTarget(c8483333.sptg)
	e1:SetOperation(c8483333.spop)
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	c:RegisterEffect(e1)
end
-- 准备阶段效果的发动条件：当前回合玩家是自己
function c8483333.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤出存在于墓地、因召唤而被解放、且解放时的上级召唤怪兽是这张卡，并且可以特殊召唤的怪兽
function c8483333.spfilter(c,e,tp,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_SUMMON) and c:GetReasonCard()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 准备阶段效果的发动准备：获取作为上级召唤祭品的怪兽，并设置特殊召唤的操作信息
function c8483333.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetHandler():GetMaterial():Filter(c8483333.spfilter,nil,e,tp,e:GetHandler())
	-- 设置特殊召唤的操作信息，包含要特殊召唤的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 准备阶段效果的执行：将作为祭品的怪兽尽可能特殊召唤到自己场上，并施加不能攻击和效果无效化的限制
function c8483333.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local c=e:GetHandler()
	local g=c:GetMaterial():Filter(c8483333.spfilter,nil,e,tp,c)
	if g:GetCount()>0 then
		if g:GetCount()>ft then
			-- 向玩家发送选择特殊召唤怪兽的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=g:Select(tp,ft,ft,nil)
		end
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽以表侧表示逐步特殊召唤到自己场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽不能攻击宣言
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
			tc=g:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
