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
-- 效果发动的目标判定：发动时不需要选择对象，直接允许发动，并预设置操作信息为投掷3次硬币，以便系统检测相关互动。
function c50593156.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有怪兽（仅用于预设置操作信息时的参考范围，实际破坏对象由后续投币结果决定）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置本次连锁的操作信息：包含硬币效果，投掷次数为3，由当前玩家进行投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果处理：进行3次投掷硬币，若3次都是表则破坏对方场上全部怪兽，若3次都是里则破坏自己场上全部怪兽。
function c50593156.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家投掷3次硬币，c1、c2、c3分别记录每次结果（1为表，0为里）。
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3==3 then
		-- 获取对方场上所有怪兽，作为破坏对象。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 以效果原因将对方场上全部怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	elseif c1+c2+c3==0 then
		-- 获取自己场上所有怪兽，作为破坏对象。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
		-- 以效果原因将自己场上全部怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
