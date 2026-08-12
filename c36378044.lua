--ラッキーパンチ
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时才能发动。进行3次投掷硬币，3次都是表的场合，自己从卡组抽3张卡。3次都是里的场合，这张卡破坏。此外，场上表侧表示存在的这张卡被破坏的场合，自己失去6000基本分。
function c36378044.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，对应一速的【对方怪兽的攻击宣言时才能发动】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36378044,0))  --"投掷骰子"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36378044.atkcon)
	e2:SetTarget(c36378044.atktg)
	e2:SetOperation(c36378044.atkop)
	c:RegisterEffect(e2)
	-- 诱发必发效果，对应一速的【场上表侧表示存在的这张卡被破坏的场合】
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c36378044.descon)
	e3:SetOperation(c36378044.desop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：对方怪兽攻击宣言时
function c36378044.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽攻击宣言时才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 效果处理准备：设置操作信息，准备进行3次投掷硬币
function c36378044.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，准备进行3次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
-- 效果处理：投掷3次硬币，若全为正面则抽3张卡，若全为反面则破坏此卡
function c36378044.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行3次投掷硬币
	local r1,r2,r3=Duel.TossCoin(tp,3)
	if r1+r2+r3==3 then
		-- 自己从卡组抽3张卡
		Duel.Draw(tp,3,REASON_EFFECT)
	elseif r1+r2+r3==0 then
		-- 这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 效果发动条件：此卡被破坏时且在场上的表侧表示状态
function c36378044.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果处理：自己失去6000基本分
function c36378044.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家的基本分
	local lp=Duel.GetLP(tp)
	-- 设置玩家基本分为当前基本分减去6000
	Duel.SetLP(tp,lp-6000)
end
