--PSYフレームロード・Ω
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，自己·对方的主要阶段才能发动。对方手卡随机选1张，那张卡和表侧表示的这张卡直到下次的自己准备阶段表侧除外。
-- ②：对方准备阶段，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到墓地。
-- ③：这张卡在墓地存在的场合，以自己或对方的墓地1张其他卡为对象才能发动。那张卡和这张卡回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、除外手卡与自身的效果、准备阶段将除外的卡送回墓地的效果、以及墓地回收自身和墓地其他卡的效果。
function c74586817.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己·对方的主要阶段才能发动。对方手卡随机选1张，那张卡和表侧表示的这张卡直到下次的自己准备阶段表侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74586817,0))  --"对方手卡和这张卡除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c74586817.rmcon)
	e1:SetTarget(c74586817.rmtg)
	e1:SetOperation(c74586817.rmop)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段，以自己或对方的除外状态的1张卡为对象才能发动。那张卡回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74586817,1))  --"除外的卡回到墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c74586817.tgcon)
	e2:SetTarget(c74586817.tgtg)
	e2:SetOperation(c74586817.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，以自己或对方的墓地1张其他卡为对象才能发动。那张卡和这张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c74586817.tdtg)
	e3:SetOperation(c74586817.tdop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数：必须在自己或对方的主要阶段。
function c74586817.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的发动目标判定与操作信息设置函数，检查自身是否能除外以及对方手卡是否存在可除外的卡。
function c74586817.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 检查对方手卡中是否存在至少1张可以被除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 获取对方手卡中所有可以被除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁的操作信息：除外2张卡（自身和对方手卡1张）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 效果①的效果处理函数：随机除外对方1张手卡和表侧表示的自身，并注册在下次自己准备阶段将它们送回原处的延迟效果。
function c74586817.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方手卡中的所有卡片。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if g:GetCount()==0 or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local rs=g:RandomSelect(1-tp,1)
	local rg=Group.FromCards(c,rs:GetFirst())
	-- 将自身和随机选出的对方手卡以暂时除外的形式表侧表示除外，并检查是否成功除外。
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=c:GetFieldID()
		-- 获取本次操作实际被除外的卡片组。
		local og=Duel.GetOperatedGroup()
		if c:GetOriginalCode()~=id then
			og:RemoveCard(c)
		end
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 直到下次的自己准备阶段表侧除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(og)
		e1:SetCondition(c74586817.retcon)
		e1:SetOperation(c74586817.retop)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		-- 注册用于在下次自己准备阶段将除外卡片归还的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果②的发动条件判定函数：必须在对方的回合。
function c74586817.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动目标选择与操作信息设置函数：选择双方除外状态的1张卡作为对象。
function c74586817.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	-- 检查双方除外状态的卡中是否存在可以作为对象选择的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要回到墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74586817,2))  --"请选择要回到墓地的卡"
	-- 玩家选择双方除外状态的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置连锁的操作信息：将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的效果处理函数：将作为对象的除外状态的卡送回墓地。
function c74586817.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标卡片作为“归还”送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
-- 过滤函数，用于筛选出带有与本次除外效果相匹配的标识（fid）的卡片。
function c74586817.retfilter(c,fid)
	return c:GetFlagEffectLabel(74586817)==fid
end
-- 归还效果的发动条件判定函数，检查是否到了自己的准备阶段，且被除外的卡片中仍有带有对应标识的卡存在。
function c74586817.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否是自己（即自己的回合）。
	if Duel.GetTurnPlayer()~=tp then return false end
	local g=e:GetLabelObject()
	if not g:IsExists(c74586817.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 归还效果的处理函数，将自身返回场上，并将对方被除外的手卡送回对方手卡。
function c74586817.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(c74586817.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		if tc==e:GetHandler() then
			-- 将暂时除外的自身返回到场上。
			Duel.ReturnToField(tc)
		else
			-- 将暂时除外的对方手卡送回其原本持有者的手卡。
			Duel.SendtoHand(tc,tc:GetPreviousControler(),REASON_EFFECT)
		end
		tc=sg:GetNext()
	end
end
-- 效果③的发动目标选择与操作信息设置函数，检查自身是否能回到卡组，并选择自身以外的双方墓地1张卡作为对象。
function c74586817.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查双方墓地中是否存在自身以外的可以回到卡组的卡。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自身以外的双方墓地1张可以回到卡组的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置连锁的操作信息：将2张卡（自身和目标卡）送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果③的效果处理函数，将自身和作为对象的墓地卡片一起回到卡组并洗牌。
function c74586817.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的墓地卡片。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将自身和目标卡片送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
