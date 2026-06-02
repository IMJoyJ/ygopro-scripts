--竜姫神サフィラ
-- 效果：
-- 「祝祷的圣歌」降临。这个卡名的效果1回合只能使用1次。
-- ①：这张卡仪式召唤的回合的结束阶段以及这张卡在怪兽区域存在并从手卡·卡组有光属性怪兽被送去墓地的回合的结束阶段，可以从以下效果选择1个发动。
-- ●自己从卡组抽2张，那之后选1张手卡丢弃。
-- ●对方手卡随机选1张丢弃去墓地。
-- ●选自己墓地1只光属性怪兽加入手卡。
function c56350972.initial_effect(c)
	-- 记录这张卡上记载了卡片「祝祷的圣歌」（卡号为80566312）的事实
	aux.AddCodeList(c,80566312)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的回合的结束阶段，可以从以下效果选择1个发动。这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c56350972.regcon1)
	e1:SetOperation(c56350972.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡在怪兽区域存在并从手卡·卡组有光属性怪兽被送去墓地的回合的结束阶段，可以从以下效果选择1个发动。这个卡名的效果1回合只能使用1次。
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
-- 检查这张卡是否是通过仪式召唤特殊召唤的
function c56350972.regcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤条件：被送去墓地的卡是原本在手牌或卡组的光属性怪兽
function c56350972.regfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 检查送去墓地的卡中是否存在原本在手牌或卡组的光属性怪兽
function c56350972.regcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56350972.regfilter,1,nil)
end
-- 在符合触发条件的回合，为这张卡注册一个在当前结束阶段可以发动的效果
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
-- 过滤条件：自己墓地中可以加入手牌的光属性怪兽
function c56350972.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果的发动准备：检测3个可选效果的可用性，让玩家从中选择1个，并根据选择的效果分类设置操作信息
function c56350972.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家自身是否可以从卡组抽卡
	local b1=Duel.IsPlayerCanDraw(tp,2)
	-- 检测对方手牌数量是否不为0
	local b2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)~=0
	-- 检测自己墓地中是否存在可以加入手牌的光属性怪兽
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
	-- 让玩家从可行的效果选项中选择1个发动
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		-- 选择“自己从卡组抽2张，那之后选1张手卡丢弃”时：设置当前效果处理的操作信息为让玩家自身抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,2)
		-- 选择“自己从卡组抽2张，那之后选1张手卡丢弃”时：设置当前效果处理的操作信息为让玩家自身丢弃1张手牌
		Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
	elseif sel==2 then
		e:SetCategory(CATEGORY_HANDES)
		-- 选择“对方手卡随机选1张丢弃去墓地”时：设置当前效果处理的操作信息为让对方丢弃1张手牌
		Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
	else
		e:SetCategory(CATEGORY_TOHAND)
		-- 选择“选自己墓地1只光属性怪兽加入手卡”时：设置当前效果处理的操作信息为将自己墓地中的1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果的处理：根据之前选择的选项，分别执行“抽2张丢1张手卡”、“对方随机丢1张手卡去墓地”或“墓地光属性怪兽加入手卡”的操作
function c56350972.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 玩家自身从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
		-- 洗切玩家自身的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使前后的抽卡与丢弃手牌效果处理视为不同时处理
		Duel.BreakEffect()
		-- 玩家自身选择1张手牌丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	elseif sel==2 then
		-- 获取对方玩家的所有手牌
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(tp,1)
		-- 将选中的对方手牌送去墓地（视为丢弃）
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	else
		-- 向玩家发送选择提示信息：“请选择要加入手牌的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从自己墓地选择1只符合条件的光属性怪兽
		local g=Duel.SelectMatchingCard(tp,c56350972.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入到玩家手牌中
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家展示并确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
