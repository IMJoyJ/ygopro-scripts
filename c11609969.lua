--DD魔導賢者ケプラー
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：自己准备阶段发动。这张卡的灵摆刻度下降2（最少到1）。那之后，持有这张卡的灵摆刻度数值以上的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●以自己场上1张其他的「DD」卡为对象才能发动。那张卡回到手卡。
-- ●从卡组把1张「契约书」卡加入手卡。
function c11609969.initial_effect(c)
	-- 为这张卡添加灵摆怪兽的通用属性：可进行灵摆召唤、灵摆区发动的效果。
	aux.EnablePendulumAttribute(c)
	-- 灵摆效果①：自己不是「DD」怪兽不能灵摆召唤，且这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c11609969.splimit)
	c:RegisterEffect(e2)
	-- 灵摆效果②：自己准备阶段发动，这张卡的灵摆刻度下降2（最少到1），那之后把持有这张卡的灵摆刻度数值以上的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c11609969.sccon)
	e3:SetTarget(c11609969.sctg)
	e3:SetOperation(c11609969.scop)
	c:RegisterEffect(e3)
	-- 怪兽效果：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,11609969)
	e4:SetTarget(c11609969.thtg)
	e4:SetOperation(c11609969.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 限制条件：不是「DD」怪兽且使用灵摆召唤方式时，不能进行特殊召唤。
function c11609969.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xaf) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 发动条件：当前回合玩家是自己（自己的准备阶段）。
function c11609969.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是自己的准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选出表侧表示、不是「DD」怪兽、等级不低于lv的怪兽，用于判定要被破坏的怪兽。
function c11609969.filter(c,lv)
	return c:IsFaceup() and not c:IsSetCard(0xaf) and c:IsLevelAbove(lv)
end
-- 效果发动前的准备：计算下降后的刻度，并收集满足破坏条件的怪兽，设置破坏的操作信息。
function c11609969.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local scl=math.max(1,e:GetHandler():GetLeftScale()-2)
	-- 取得自己场上表侧表示且等级不低于下降后刻度的除「DD」怪兽以外的所有怪兽。
	local g=Duel.GetMatchingGroup(c11609969.filter,tp,LOCATION_MZONE,0,nil,scl)
	if e:GetHandler():GetLeftScale()>1 then
		-- 设置这次效果有可能破坏的怪兽组及数量，用于连锁反应和发动检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果处理：若这张卡仍存在于灵摆区且刻度大于1，则将左右灵摆刻度下降相应数值，然后破坏满足条件的怪兽。
function c11609969.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()==1 then return end
	local scl=2
	if c:GetLeftScale()==2 then scl=1 end
	-- 使这张卡的左灵摆刻度下降scl（实际在下降后的基础上再根据原刻度调整）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(-scl)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
	-- 按下降后的当前刻度，取得自己场上满足破坏条件的怪兽。
	local g=Duel.GetMatchingGroup(c11609969.filter,tp,LOCATION_MZONE,0,nil,c:GetLeftScale())
	if g:GetCount()>0 then
		-- 中断当前效果处理链，使后续的破坏处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 把满足条件的怪兽全部以效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 筛选自己场上表侧表示的其他「DD」卡，且能够回到手卡。
function c11609969.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsAbleToHand()
end
-- 筛选卡组中持有「契约书」字段且能够加入手卡的卡。
function c11609969.filter2(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- 选择效果发动时的目标/检索判定：可以选择自己场上1张其他「DD」卡加入手卡，或从卡组把1张「契约书」卡加入手卡。
function c11609969.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c11609969.filter1(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在1张其他表侧表示「DD」卡可以作为对象。
	local b1=Duel.IsExistingTarget(c11609969.filter1,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
	-- 检查卡组中是否存在1张「契约书」卡可以加入手卡。
	local b2=Duel.IsExistingMatchingCard(c11609969.filter2,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 两个选项都可用时，让玩家选择其中一个选项。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(11609969,0),aux.Stringid(11609969,1))  --"自己场上1张「DD」卡回到手卡/自己卡组1张「契约书」卡加入手卡"
	-- 只有回收「DD」卡选项可用时，自动选择该选项。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(11609969,0))  --"自己场上1张「DD」卡回到手卡"
	-- 只有检索「契约书」卡选项可用时，自动选择该选项（并调整op标记）。
	else op=Duel.SelectOption(tp,aux.Stringid(11609969,1))+1 end  --"自己卡组1张「契约书」卡加入手卡"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 提示玩家选择要返回手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己场上1张其他「DD」卡作为效果对象。
		local g=Duel.SelectTarget(tp,c11609969.filter1,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
		-- 记录把对象卡返回手卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 记录从卡组检索「契约书」卡加入手卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理：若选择回收则把对象「DD」卡返回手卡；若选择检索则从卡组把1张「契约书」卡加入手卡。
function c11609969.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 取得作为效果对象的那张卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将该对象卡返回持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认返回手卡的卡。
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「契约书」卡。
		local g=Duel.SelectMatchingCard(tp,c11609969.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将检索到的「契约书」卡加入持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
