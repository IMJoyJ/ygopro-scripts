--巨大戦艦 カバード・コア
-- 效果：
-- 这张卡召唤时放置2个指示物。这张卡不会被战斗破坏。进行战斗的场合，在伤害步骤结束时投掷硬币猜正反。猜错的场合，卡上的1个指示物取除。没有指示物放置的状态进行战斗的场合，伤害步骤结束时这张卡破坏。
function c15317640.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这张卡召唤时放置2个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15317640,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c15317640.addct)
	e1:SetOperation(c15317640.addc)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 进行战斗的场合，在伤害步骤结束时投掷硬币猜正反。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15317640,1))  --"投掷硬币"
	e3:SetCategory(CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c15317640.rctcon)
	e3:SetTarget(c15317640.rcttg)
	e3:SetOperation(c15317640.rctop)
	c:RegisterEffect(e3)
	-- 没有指示物放置的状态进行战斗的场合，伤害步骤结束时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15317640,2))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c15317640.descon)
	e4:SetTarget(c15317640.destg)
	e4:SetOperation(c15317640.desop)
	c:RegisterEffect(e4)
end
-- 设置效果处理时将要放置2个指示物
function c15317640.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为放置2个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1f)
end
-- 将2个指示物放置到自身上
function c15317640.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,2)
	end
end
-- 判断自身是否具有指示物
function c15317640.rctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1f)~=0
end
-- 设置效果处理时将要投掷硬币
function c15317640.rcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为投掷1次硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 执行投掷硬币效果，若猜对则取除1个指示物
function c15317640.rctop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷1次硬币
	local res=Duel.TossCoin(tp,1)
	if coin==res then
		e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_EFFECT)
	end
end
-- 判断是否在战斗阶段且无指示物
function c15317640.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1f)==0 and e:GetHandler():IsRelateToBattle()
end
-- 设置效果处理时将要破坏自身
function c15317640.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 若自身表侧表示且存在于场上则破坏自身
function c15317640.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将自身破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
