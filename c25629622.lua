--魔界劇団－ビッグ・スター
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡加入手卡。
-- 【怪兽效果】
-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
-- ②：1回合1次，自己主要阶段才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。这个效果盖放的卡在结束阶段送去墓地。
function c25629622.initial_effect(c)
	-- 使这张卡成为灵摆怪兽，获得在灵摆区发动和作为灵摆刻度的能力，并启用灵摆召唤相关规则处理。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把自己场上1只「魔界剧团」怪兽解放，以自己墓地1张「魔界台本」魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25629622,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c25629622.thcost)
	e1:SetTarget(c25629622.thtg)
	e1:SetOperation(c25629622.thop)
	c:RegisterEffect(e1)
	-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c25629622.limop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ①：在这张卡的召唤·特殊召唤成功时对方不能把魔法·陷阱卡的效果发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_CHAIN_END)
	e0:SetOperation(c25629622.limop2)
	c:RegisterEffect(e0)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。这个效果盖放的卡在结束阶段送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c25629622.settg)
	e4:SetOperation(c25629622.setop)
	c:RegisterEffect(e4)
end
-- 发动代价：从自己场上选择1只「魔界剧团」怪兽解放。
function c25629622.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只「魔界剧团」怪兽可以作为解放代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x10ec) end
	-- 选择1只「魔界剧团」怪兽用于解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x10ec)
	-- 将选择的怪兽解放，作为发动该效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：从自己墓地选择1张「魔界台本」魔法卡且能够加入手卡。
function c25629622.thfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 选择自己墓地1张符合条件的「魔界台本」魔法卡作为对象，并设置加入手卡的操作信息。
function c25629622.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25629622.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的「魔界台本」魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c25629622.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向当前玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「魔界台本」魔法卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c25629622.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果会把对象卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时，若目标卡仍与效果关联，则将其加入手卡。
function c25629622.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去持有者的手卡（即加入手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 这张卡召唤成功时，若当前不在连锁中则立即设置限制；若已在连锁中则记录标记，待连锁结束时再设置限制。
function c25629622.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁数为0，即这张卡召唤成功时没有其他效果正在连锁处理。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束的连锁限制：只允许本卡控制者发动的效果或怪兽效果发动，从而禁止对方发动魔法·陷阱卡的效果。
		Duel.SetChainLimitTillChainEnd(c25629622.chlimit)
	-- 如果当前连锁数为1，表示召唤成功时已经有其他效果正在处理，先给自己的卡记录一个标记，待连锁结束时再补设限制。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(25629622,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 连锁限制条件：只允许本卡控制者发动的效果或怪兽效果发动，以此禁止对方发动魔法·陷阱卡的效果。
function c25629622.chlimit(e,rp,tp)
	return tp==rp or e:IsActiveType(TYPE_MONSTER)
end
-- 连锁结束时检查是否有待处理的封锁标记，若有则设置连锁限制，然后清除标记。
function c25629622.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(25629622)~=0 then
		-- 在连锁结束时补设直到连锁结束的连锁限制，封锁对方魔法·陷阱卡的发动。
		Duel.SetChainLimitTillChainEnd(c25629622.chlimit)
	end
	e:GetHandler():ResetFlagEffect(25629622)
end
-- 过滤条件：选择卡组中1张「魔界台本」魔法卡且能够盖放到魔法与陷阱区域。
function c25629622.setfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 起动效果的目标：确认卡组中存在1张符合条件的「魔界台本」魔法卡。
function c25629622.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c25629622.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选1张「魔界台本」魔法卡盖放到自己场上；盖放成功时给该卡记录标记，并注册结束阶段将其送去墓地的效果。
function c25629622.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要盖放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张符合条件的「魔界台本」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c25629622.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若选出的卡存在且成功盖放到自己场上，则继续为该卡注册结束阶段送墓的效果。
	if tc and Duel.SSet(tp,tc)~=0 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(25629622,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果盖放的卡在结束阶段送去墓地。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c25629622.tgcon)
		e1:SetOperation(c25629622.tgop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将结束阶段把盖放的「魔界台本」卡送去墓地的效果注册到游戏中。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断结束阶段时该卡是否为本次效果盖放的卡（通过记录标记和效果标签对照）。
function c25629622.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(25629622)==e:GetLabel()
end
-- 效果处理：将该盖放的「魔界台本」魔法卡送去墓地。
function c25629622.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将那张「魔界台本」魔法卡以效果原因送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
