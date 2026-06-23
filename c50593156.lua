--サンド・ギャンブラー
-- 效果：
-- 进行3次投掷硬币。3次都是表的场合，对方场上怪兽全部破坏。3次都是里的场合，自己场上怪兽全部破坏。这个效果1回合只有1次在自己的主要阶段才能使用。
function c50593156.initial_effect(c)
	-- 进行3次投掷硬币。3次都是表的场合，对方场上怪兽全部破坏。3次都是里的场合，自己场上怪兽全部破坏。这个效果1回合只有1次在自己的主要阶段才能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50593156,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c50593156.destg)
	e1:SetOperation(c50593156.desop)
	c:RegisterEffect(e1)
end
-- 投掷硬币
function c50593156.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息为硬币效果
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 进行3次投掷硬币。3次都是表的场合，对方场上怪兽全部破坏。3次都是里的场合，自己场上怪兽全部破坏。这个效果1回合只有1次在自己的主要阶段才能使用。
function c50593156.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投3次硬币，返回值为3个结果，0或者1, 正面是 1，反面是0
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		-- 检索满足条件的卡片组
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 以效果原因破坏targets去墓地
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==0 then
		-- 检索满足条件的卡片组
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 以效果原因破坏targets去墓地
		Duel.Destroy(g,REASON_EFFECT)
	end
end
