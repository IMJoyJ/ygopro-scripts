--伝説の賭博師
-- 效果：
-- 进行3次投掷硬币。
-- ●3次都是表的场合，对方场上怪兽全部破坏。
-- ●2次表的场合，对方手卡随机丢弃1张。
-- ●1次表的场合，自己场上存在的1张卡破坏。
-- ●3次都是里的场合，自己手卡全部丢弃。
-- 这个效果1回合只有1次在自己的主要阶段才能使用。
function c2196767.initial_effect(c)
	-- 创建效果，设置效果描述为“投掷硬币”，设置效果类别为破坏、弃牌和硬币效果，设置效果类型为起动效果，设置效果适用范围为主怪兽区，设置每回合只能发动1次，设置效果目标函数为c2196767.destg，设置效果处理函数为c2196767.desop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2196767,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c2196767.destg)
	e1:SetOperation(c2196767.desop)
	c:RegisterEffect(e1)
end
-- 效果目标函数，检查是否可以发动效果并设置操作信息为投掷3次硬币
function c2196767.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示本次连锁将进行3次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果处理函数，根据投掷结果执行不同效果
function c2196767.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行3次硬币投掷，返回3个结果（0或1）
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		-- 获取对方场上所有怪兽作为目标
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 将目标怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==2 then
		-- 获取对方手牌并随机选择1张
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
		-- 将选择的对方手牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif c1+c2+c3==1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上1张卡作为目标
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	else
		-- 获取自己的所有手牌
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		-- 将自己的所有手牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end
