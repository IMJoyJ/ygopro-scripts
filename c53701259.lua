--覚醒の三幻魔
-- 效果：
-- ①：得到自己场上的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」种类数量的以下效果。
-- ●1种类以上：每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分。
-- ●2种类以上：对方场上的怪兽发动的效果无效化。
-- ●3种类：被送去对方墓地的怪兽不去墓地而除外。
-- ②：自己回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地选1张永续陷阱卡加入手卡。
function c53701259.initial_effect(c)
	-- 记录该卡拥有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」这三张卡的卡名
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(1)
	e2:SetCondition(c53701259.lpcon)
	e2:SetOperation(c53701259.lpop1)
	c:RegisterEffect(e2)
	-- 每次对方对怪兽的召唤·特殊召唤成功，自己回复那些怪兽的攻击力数值的基本分
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabel(1)
	e3:SetCondition(c53701259.lpcon1)
	e3:SetOperation(c53701259.lpop1)
	c:RegisterEffect(e3)
	-- 对方场上的怪兽发动的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabel(1)
	e4:SetCondition(c53701259.regcon)
	e4:SetOperation(c53701259.regop)
	c:RegisterEffect(e4)
	-- 被送去对方墓地的怪兽不去墓地而除外
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c53701259.lpcon2)
	e5:SetOperation(c53701259.lpop2)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 对方场上的怪兽发动的效果无效化
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetLabel(2)
	e6:SetCondition(c53701259.discon)
	e6:SetOperation(c53701259.disop)
	c:RegisterEffect(e6)
	-- 被送去对方墓地的怪兽不去墓地而除外
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetRange(LOCATION_SZONE)
	e7:SetValue(LOCATION_REMOVED)
	e7:SetTargetRange(0,LOCATION_DECK)
	e7:SetTarget(c53701259.rmtg)
	e7:SetCondition(c53701259.rmcon)
	c:RegisterEffect(e7)
	-- 自己回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地选1张永续陷阱卡加入手卡
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(53701259,0))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCost(c53701259.thcon)
	e8:SetTarget(c53701259.thtg)
	e8:SetOperation(c53701259.thop)
	c:RegisterEffect(e8)
end
-- 过滤出自己场上表侧表示的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
function c53701259.filter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822,69890967)
end
-- 判断一张卡是否为指定玩家召唤的表侧表示怪兽
function c53701259.cfilter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsFaceup()
end
-- 判断自己场上是否存在指定数量的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
function c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上表侧表示的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
	local g=Duel.GetMatchingGroup(c53701259.filter,tp,LOCATION_ONFIELD,0,nil)
	local ct=e:GetLabel()
	return ct and g:GetClassCount(Card.GetCode)>=ct
end
-- 判断对方召唤或特殊召唤的怪兽是否为表侧表示
function c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
		and eg:IsExists(c53701259.cfilter,1,nil,1-tp)
end
-- 判断对方召唤或特殊召唤的怪兽是否为表侧表示
function c53701259.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 确保连锁未处理中
		and not Duel.IsChainSolving()
end
-- 计算对方召唤或特殊召唤的怪兽攻击力总和并回复给玩家
function c53701259.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c53701259.cfilter,nil,1-tp)
	local rnum=lg:GetSum(Card.GetAttack)
	-- 回复玩家基本分
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 判断对方召唤或特殊召唤的怪兽是否为表侧表示
function c53701259.regcon(e,tp,eg,ep,ev,re,r,rp)
	return c53701259.lpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 确保连锁正在处理中
		and Duel.IsChainSolving()
end
-- 记录对方召唤或特殊召唤的怪兽攻击力总和
function c53701259.regop(e,tp,eg,ep,ev,re,r,rp)
	local lg=eg:Filter(c53701259.cfilter,nil,1-tp)
	local g=e:GetLabelObject()
	if g==nil or #g==0 then
		lg:KeepAlive()
		e:SetLabelObject(lg)
	else
		g:Merge(lg)
	end
	e:GetHandler():RegisterFlagEffect(53701259,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
end
-- 判断是否已记录对方召唤或特殊召唤的怪兽攻击力总和
function c53701259.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53701259)>0
end
-- 取出记录的对方召唤或特殊召唤的怪兽攻击力总和并回复给玩家
function c53701259.lpop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(53701259)
	local lg=e:GetLabelObject():GetLabelObject()
	local rnum=lg:GetSum(Card.GetAttack)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
	lg:DeleteGroup()
	-- 回复玩家基本分
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
-- 判断对方发动的怪兽效果是否在场上发动
function c53701259.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁触发位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return c53701259.condition(e,tp,eg,ep,ev,re,r,rp)
		and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and rp==1-tp
end
-- 使连锁效果无效
function c53701259.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 判断一张卡是否为对方所有且原本为怪兽
function c53701259.rmtg(e,c)
	-- 判断一张卡是否为对方所有且原本为怪兽
	return c:GetOwner()~=e:GetHandlerPlayer() and aux.DimensionalFissureTarget(e,c)
end
-- 判断自己场上是否同时存在三种「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
function c53701259.rmcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检索自己场上表侧表示的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」
	local g=Duel.GetMatchingGroup(c53701259.filter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)==3
end
-- 过滤出自己场上表侧表示的10星怪兽
function c53701259.ffilter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- 判断自己场上是否存在10星怪兽且为当前回合玩家
function c53701259.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在10星怪兽且为当前回合玩家
	return Duel.IsExistingMatchingCard(c53701259.ffilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetTurnPlayer()==tp
end
-- 过滤出墓地中可加入手牌的永续陷阱卡
function c53701259.thfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时要处理的卡
function c53701259.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53701259.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 选择并加入手牌一张永续陷阱卡
function c53701259.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中一张永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53701259.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
