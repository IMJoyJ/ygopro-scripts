--PSYフレームロード・Ζ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的场合，以这张卡以外的自己墓地1张「PSY骨架」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，设置同调召唤条件并注册两个效果
function c37192109.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：1回合1次，以对方场上1只特殊召唤的表侧攻击表示怪兽为对象才能发动。那只怪兽和场上的这张卡直到下次的自己准备阶段除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37192109,0))  --"对方怪兽和这张卡除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37192109.rmtg)
	e1:SetOperation(c37192109.rmop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在墓地存在的场合，以这张卡以外的自己墓地1张「PSY骨架」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37192109,1))  --"「PSY骨架」卡回到手卡"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c37192109.thtg)
	e2:SetOperation(c37192109.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧攻击表示、能除外、是特殊召唤的怪兽
function c37192109.rmfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToRemove()
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果①的发动时点处理，判断是否能选择目标怪兽
function c37192109.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c37192109.rmfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 判断是否能选择目标怪兽
		and Duel.IsExistingTarget(c37192109.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽和自身
	local g=Duel.SelectTarget(tp,c37192109.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置效果操作信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 效果①的处理函数，将目标怪兽和自身除外并设置返回效果
function c37192109.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	-- 将目标怪兽和自身除外
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		local rct=1
		-- 判断是否为自己的准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then rct=2 end
		-- 获取实际操作的卡片组
		local og=Duel.GetOperatedGroup()
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,rct,fid)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 设置一个在准备阶段触发的效果，用于将除外的卡返回场上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(c37192109.retcon)
		e1:SetOperation(c37192109.retop)
		-- 判断是否为自己的准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 设置该效果的触发次数
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 注册该效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断卡片是否为本次除外的卡片
function c37192109.retfilter(c,fid)
	return c:GetFlagEffectLabel(37192109)==fid
end
-- 准备阶段触发效果的条件判断函数
function c37192109.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段且不是第一次触发
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c37192109.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 准备阶段触发效果的处理函数，将除外的卡返回场上
function c37192109.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c37192109.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		-- 将卡片返回场上
		Duel.ReturnToField(tc)
		tc=sg:GetNext()
	end
end
-- 过滤条件：PSY骨架卡组且能加入手牌
function c37192109.thfilter(c)
	return c:IsSetCard(0xc1) and c:IsAbleToHand()
end
-- 效果②的发动时点处理，判断是否能选择目标墓地的PSY骨架卡
function c37192109.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37192109.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 判断是否能选择目标墓地的PSY骨架卡
		and Duel.IsExistingTarget(c37192109.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标墓地的PSY骨架卡
	local g=Duel.SelectTarget(tp,c37192109.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果操作信息为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果操作信息为回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数，将卡回到额外卡组并将目标卡加入手牌
function c37192109.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 判断卡是否有效且已回到额外卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
