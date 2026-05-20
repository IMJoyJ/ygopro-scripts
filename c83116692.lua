--死眼の伝霊－プシュコポンポス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合发动。对方墓地的以下的卡之内数量较多方的效果适用。
-- ●怪兽卡：这张卡除外，对方从自身墓地选1只怪兽除外。
-- ●魔法·陷阱卡：这张卡送去墓地，对方选自身场上1只怪兽送去墓地。
-- ②：这张卡被除外的场合，下个回合的结束阶段才能发动。除外的这张卡特殊召唤。
function c83116692.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合发动。对方墓地的以下的卡之内数量较多方的效果适用。●怪兽卡：这张卡除外，对方从自身墓地选1只怪兽除外。●魔法·陷阱卡：这张卡送去墓地，对方选自身场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83116692,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,83116692)
	e1:SetTarget(c83116692.rmtg)
	e1:SetOperation(c83116692.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，下个回合的结束阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83116692,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,83116693)
	e3:SetCondition(c83116692.spcon)
	e3:SetTarget(c83116692.sptg)
	e3:SetOperation(c83116692.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡被除外的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_REMOVE)
	e4:SetOperation(c83116692.regop)
	c:RegisterEffect(e4)
end
-- 过滤条件：对方墓地中可以被除外的怪兽卡
function c83116692.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 过滤条件：对方场上可以送去墓地的怪兽卡
function c83116692.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①号效果的发动准备：作为必发效果，直接返回true
function c83116692.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ①号效果的处理：比较对方墓地怪兽与魔陷数量，适用数量较多方的效果
function c83116692.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方墓地中怪兽卡的数量
	local mc=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 获取对方墓地中魔法·陷阱卡的数量
	local sc=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_SPELL+TYPE_TRAP)
	if mc>sc then
		-- 若这张卡仍在场，则将其除外，除外成功时继续处理
		if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 获取对方墓地中满足除外条件的怪兽卡（受王家长眠之谷影响）
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c83116692.rmfilter),tp,0,LOCATION_GRAVE,nil)
			if g:GetCount()>0 then
				-- 提示对方玩家选择要除外的卡
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
				local sg=g:Select(1-tp,1,1,nil)
				-- 将对方选择的墓地怪兽除外
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	elseif mc<sc then
		-- 若这张卡仍在场，则将其送去墓地，送墓成功时继续处理
		if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
			-- 获取对方场上满足送墓条件的怪兽卡
			local g=Duel.GetMatchingGroup(c83116692.tgfilter,tp,0,LOCATION_MZONE,nil)
			if g:GetCount()>0 then
				-- 提示对方玩家选择要送去墓地的卡
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=g:Select(1-tp,1,1,nil)
				-- 将对方选择的场上怪兽送去墓地
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
-- 在自身被除外时，给自身注册一个持续到下个回合结束阶段的Flag，用于记录除外状态
function c83116692.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(83116692,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- ②号效果的发动条件：非被除外的当回合，且自身带有被除外时注册的Flag
function c83116692.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合不是被除外的回合，且存在对应的Flag
	return c:GetTurnID()~=Duel.GetTurnCount() and c:GetFlagEffect(83116692)>0
end
-- ②号效果的发动准备：确认自身可以特殊召唤且己方场上有空位
function c83116692.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②号效果的处理：将除外的这张卡特殊召唤
function c83116692.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
