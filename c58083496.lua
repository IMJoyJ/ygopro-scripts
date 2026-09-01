--Odd-Eyes Override Dragon
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 包含灵摆怪兽的怪兽2只或3只
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1张其他卡为对象才能发动。那张卡破坏，自己抽1张。破坏的卡是灵摆怪兽卡的场合，这个回合自己在通常的灵摆召唤外加上只有1次，在自己的主要阶段可以把「娱乐伙伴」怪兽·「异色眼」怪兽·「魔术师」灵摆怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：自己回合对方把效果发动时，把1张手卡丢弃才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤作为连接素材的灵摆怪兽
function s.mfilter(c)
	return c:IsLinkType(TYPE_PENDULUM)
end
-- 连接素材检查：素材中必须包含灵摆怪兽
function s.lcheck(g,lc)
	return g:IsExists(s.mfilter,1,nil)
end
-- ①效果的目标：选择场上1张卡并设置抽卡信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc~=e:GetHandler() end
	-- 检查自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己场上是否存在除自身以外的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上除自身以外的1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的处理：破坏目标卡、抽1张卡并根据灵摆卡追加额外灵摆召唤
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡片
	local tc=Duel.GetFirstTarget()
	-- 破坏目标卡片
	if tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		if tc:IsType(TYPE_PENDULUM) then
			-- 这个回合自己在通常的灵摆召唤外加上只有1次，在自己的主要阶段可以把「娱乐伙伴」怪兽·「异色眼」怪兽·「魔术师」灵摆怪兽灵摆召唤
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetCountLimit(1,id+o*2)
			e1:SetValue(s.pendvalue)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册额外灵摆召唤效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 过滤可以进行额外灵摆召唤的怪兽
function s.pendvalue(e,c)
	return c:IsSetCard(0x9f,0x99) or c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- ②效果的发动条件：自己回合对方发动效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查是否为自己回合且对方发动了可无效的效果
	return Duel.IsChainDisablable(ev) and Duel.GetTurnPlayer()==tp and rp==1-tp
end
-- ②效果的代价：丢弃1张手牌
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否有可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的目标：设置无效连锁的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果的处理：无效连锁效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该发动效果
	Duel.NegateEffect(ev)
end
