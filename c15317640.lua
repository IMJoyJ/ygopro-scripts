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
	-- 进行战斗的场合，在伤害步骤结束时投掷硬币猜正反。猜错的场合，卡上的1个指示物取除。
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
-- 召唤成功时放置指示物效果的发动判定：无特殊条件即允许发动，并预设置将放置2个指示物的操作信息。
function c15317640.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁处理将放置2个指示物（指示物类型0x1f），用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1f)
end
-- 效果处理时，若这张卡仍与效果关联，则给它放置2个指示物。
function c15317640.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,2)
	end
end
-- 投硬币效果的发动条件：这张卡上存在至少1个指示物，即有指示物才需要猜正反。
function c15317640.rctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1f)~=0
end
-- 投硬币效果的发动判定：允许发动，并预设置本次效果包含硬币投掷。
function c15317640.rcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果将进行硬币投掷（1次）。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 处理时先让玩家宣言硬币正反面，再实际投掷1次硬币；若判定为猜错，则取除这张卡的1个指示物。
function c15317640.rctop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择硬币的正反面”的提示，等待玩家宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面，得到宣言值。
	local coin=Duel.AnnounceCoin(tp)
	-- 实际投掷1枚硬币，获得正反结果。
	local res=Duel.TossCoin(tp,1)
	if coin==res then
		e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_EFFECT)
	end
end
-- 自毁效果的发动条件：这张卡上没有指示物，且它仍与本次战斗关联。
function c15317640.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1f)==0 and e:GetHandler():IsRelateToBattle()
end
-- 自毁效果的发动判定：允许发动，并预设置将这张卡自身作为破坏对象。
function c15317640.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果将破坏这张卡自身（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡表侧表示且仍与效果关联，则将其破坏。
function c15317640.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
