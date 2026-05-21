--バベル・タワー
-- 效果：
-- 只要这张卡在场上存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。这张卡放置第4个魔力指示物时这张卡破坏，那个时候把魔法卡发动的玩家受到3000分伤害。
function c94256039.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 在连锁发生时，标记这张卡在场上存在。
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。这张卡放置第4个魔力指示物时这张卡破坏，那个时候把魔法卡发动的玩家受到3000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c94256039.acop)
	c:RegisterEffect(e3)
	-- 这张卡放置第4个魔力指示物时这张卡破坏，那个时候把魔法卡发动的玩家受到3000分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94256039,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+94256039)
	e4:SetTarget(c94256039.damtg)
	e4:SetOperation(c94256039.damop)
	c:RegisterEffect(e4)
	-- 这张卡放置第4个魔力指示物时这张卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ADD_COUNTER+0x1)
	e5:SetCondition(c94256039.descon)
	e5:SetTarget(c94256039.destg)
	e5:SetOperation(c94256039.desop)
	c:RegisterEffect(e5)
end
-- 连锁处理完毕时，若有魔法卡发动且此卡在场，则给此卡放置1个魔力指示物；若指示物达到4个，则触发自定义事件。
function c94256039.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动该魔法卡的玩家。
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and c:GetFlagEffect(FLAG_ID_CHAINING)>0 then
		c:AddCounter(0x1,1)
		if c:GetCounter(0x1)==4 then
			-- 触发自定义事件，传入发动魔法卡的效果和玩家参数，用于后续处理破坏和伤害。
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+94256039,re,0,0,p,0)
		end
	end
end
-- 放置第4个魔力指示物时触发效果的靶向/声明处理，确认此卡在场并设置破坏与伤害的操作信息。
function c94256039.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息：给与发动魔法卡的玩家3000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,ep,3000)
	-- 设置操作信息：破坏自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 放置第4个魔力指示物时触发效果的实际处理：破坏自身并给与发动魔法卡的玩家3000点伤害。
function c94256039.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试以效果破坏自身，若成功破坏则执行后续伤害处理。
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 给与发动魔法卡的玩家3000点伤害。
		Duel.Damage(ep,3000,REASON_EFFECT)
	end
end
-- 检查是否因其他卡的效果放置了指示物，且当前魔力指示物数量达到4个以上。
function c94256039.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and e:GetHandler():GetCounter(0x1)>=4
end
-- 放置第4个魔力指示物时破坏效果的靶向/声明处理，设置破坏自身的操作信息。
function c94256039.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：破坏自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 放置第4个魔力指示物时破坏效果的实际处理：破坏自身。
function c94256039.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
