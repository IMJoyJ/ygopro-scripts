--竜姫神サフィラ
-- 效果：
-- 「祝祷的圣歌」降临。这个卡名的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的回合的结束阶段以及这张卡在怪兽区域存在并从手卡·卡组有光属性怪兽被送去墓地的回合的结束阶段，可以从以下效果选择1个发动。
-- ●自己从卡组抽2张，那之后选1张手卡丢弃。
-- ●对方手卡随机选1张丢弃去墓地。
-- ●选自己墓地1只光属性怪兽加入手卡。
function c56350972.initial_effect(c)
	aux.AddCodeList(c,80566312)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的回合的结束阶段……可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c56350972.regcon1)
	e1:SetOperation(c56350972.regop)
	c:RegisterEffect(e1)
	-- ①：……以及这张卡在怪兽区域存在并从手卡·卡组有光属性怪兽被送去墓地的回合的结束阶段，可以从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c56350972.regcon2)
	e2:SetOperation(c56350972.regop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否进行了仪式召唤。
function c56350972.regcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤从手卡或卡组送去墓地的光属性怪兽。
function c56350972.regfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 检查是否有光属性怪兽从手卡或卡组送去墓地。
function c56350972.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56350972.regfilter,1,nil)
end
-- 在回合结束阶段注册一个可以发动选择效果的诱发效果。
function c56350972.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●自己从卡组抽2张，那之后选1张手卡丢弃。●对方手卡随机选1张丢弃去墓地。●选自己墓地1只光属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56350972,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1,56350972)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c56350972.target)
	e1:SetOperation(c56350972.operation)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地可以加入手卡的光属性怪兽。
function c56350972.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 检查可发动的效果选项，由玩家选择其中一个，并设置对应的操作信息。
function c56350972.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽卡。
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检查对方手卡是否不为0张。
	local b2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0
	-- 检查自己墓地是否存在可以加入手卡的光属性怪兽。
	local b3=Duel.IsExistingMatchingCard(c56350972.filter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(56350972,1)  --"自己从卡组抽2张，那之后选1张手卡丢弃"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(56350972,2)  --"对方手卡随机选1张丢弃去墓地"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(56350972,3)  --"选自己墓地1只光属性怪兽加入手卡"
		opval[off-1]=3
		off=off+1
	end
	-- 让玩家选择要发动的效果选项。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		-- 设置效果处理信息为自己抽2张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,2)
		-- 设置效果处理信息为自己丢弃1张手卡。
		Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
	elseif sel==2 then
		e:SetCategory(CATEGORY_HANDES)
		-- 设置效果处理信息为对方丢弃1张手卡。
		Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
	else
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置效果处理信息为将自己墓地1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 根据玩家选择的效果选项，执行对应的效果处理。
function c56350972.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 让自己从卡组抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使后续的丢弃手卡处理不与抽卡同时进行。
		Duel.BreakEffect()
		-- 让玩家选择并丢弃1张手卡。
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	elseif sel==2 then
		-- 获取对方的所有手卡。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(tp,1)
		-- 将选中的对方手卡丢弃去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	else
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家选择自己墓地1只满足条件的光属性怪兽。
		local g=Duel.SelectMatchingCard(tp,c56350972.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
