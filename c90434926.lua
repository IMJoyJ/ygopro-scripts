--漆黒のトバリ
-- 效果：
-- 自己的抽卡阶段抽到的卡是暗属性怪兽的场合，可以把那张卡给对方观看，那张卡送去墓地。那之后，可以从自己卡组抽1张卡。
function c90434926.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的抽卡阶段抽到的卡是暗属性怪兽的场合，可以把那张卡给对方观看，那张卡送去墓地。那之后，可以从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90434926,0))  --"再次抽卡"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c90434926.drcon)
	e2:SetCost(c90434926.drcost)
	e2:SetTarget(c90434926.drtg)
	e2:SetOperation(c90434926.drop)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数：检查是否在自己的抽卡阶段
function c90434926.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己，且当前阶段是否为抽卡阶段
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 定义过滤函数：筛选手卡中未公开的暗属性怪兽
function c90434926.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 定义效果发动代价函数：将抽到的暗属性怪兽给对方观看
function c90434926.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(c90434926.filter,1,nil) end
	local g=eg:Filter(c90434926.filter,nil)
	if g:GetCount()==1 then
		-- 给对方确认抽到的那张暗属性怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手卡，重置手卡公开状态
		Duel.ShuffleHand(tp)
		e:SetLabelObject(g:GetFirst())
	else
		-- 设置提示信息：请选择给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 给对方确认选中的那张暗属性怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切手卡，重置手卡公开状态
		Duel.ShuffleHand(tp)
		e:SetLabelObject(sg:GetFirst())
	end
end
-- 定义效果目标函数：建立卡片与效果的联系，并设置送去墓地的操作信息
function c90434926.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	tc:CreateEffectRelation(e)
	-- 设置操作信息：将该卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
-- 定义效果处理函数：将确认的卡送去墓地，之后可以抽1张卡
function c90434926.drop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	-- 将确认的暗属性怪兽送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
	-- 判断该卡是否成功送去墓地、自己是否可以抽卡，并由玩家选择是否抽卡
	if tc:IsLocation(LOCATION_GRAVE) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(90434926,1)) then  --"是否要抽卡？"
		-- 中断当前效果处理，使后续的抽卡处理不与送墓同时进行（错时点）
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
