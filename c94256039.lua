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
	-- 注册连锁登记，用于检测魔法卡的发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 设置连锁注册操作：标记发动的连锁卡片
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
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
	-- 其它效果使指示物达到4个以上时强制发动：破坏这张卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ADD_COUNTER+0x1)
	e5:SetCondition(c94256039.descon)
	e5:SetTarget(c94256039.destg)
	e5:SetOperation(c94256039.desop)
	c:RegisterEffect(e5)
end
c94256039.mentioned_counter={
	[0x1]=true,
}
-- 魔法卡发动处理：在魔法卡处理后放置指示物，满4个时触发伤害事件
function c94256039.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取引发该魔法卡发动的玩家
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER)
	local c=e:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and c:GetFlagEffect(FLAG_ID_CHAINING)>0 then
		c:AddCounter(0x1,1)
		if c:GetCounter(0x1)==4 then
			-- 触发自定义事件，记录引发发动的玩家以处理后续3000伤害
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+94256039,re,0,0,p,0)
		end
	end
end
-- 破坏与伤害效果准备：设置伤害3000与破坏自身的连锁操作信息
function c94256039.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置连锁操作信息：给予引发发动的玩家3000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,ep,3000)
	-- 设置连锁操作信息：破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏与伤害效果处理：成功破坏这张卡后给予玩家3000点伤害
function c94256039.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否被成功破坏
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 给予引发发动的玩家3000点效果伤害
		Duel.Damage(ep,3000,REASON_EFFECT)
	end
end
-- 破坏效果发动条件检查：非自身效果放置指示物且指示物数量达到4个以上
function c94256039.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler() and e:GetHandler():GetCounter(0x1)>=4
end
-- 破坏效果发动准备：设置破坏自身的连锁操作信息
function c94256039.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果处理：破坏这张卡
function c94256039.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
