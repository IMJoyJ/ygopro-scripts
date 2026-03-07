--Emハットトリッカー
-- 效果：
-- ①：场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。给这张卡放置1个娱乐法师指示物（最多3个）。那之后，那个效果让自己受到的伤害变成0。
-- ③：这张卡有娱乐法师指示物被放置，那些娱乐法师指示物变成3个时，这张卡的攻击力·守备力变成3300。
function c31292357.initial_effect(c)
	c:EnableCounterPermit(0x36)
	c:SetCounterLimit(0x36,3)
	-- 效果原文内容：①：场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c31292357.spcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。给这张卡放置1个娱乐法师指示物（最多3个）。那之后，那个效果让自己受到的伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 规则层面作用：判断是否满足效果发动条件，即玩家受到伤害
	e2:SetCondition(aux.damcon1)
	e2:SetTarget(c31292357.cttg)
	e2:SetOperation(c31292357.ctop)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：这张卡有娱乐法师指示物被放置，那些娱乐法师指示物变成3个时，这张卡的攻击力·守备力变成3300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADD_COUNTER+0x36)
	e3:SetCondition(c31292357.atkcon)
	e3:SetOperation(c31292357.atkop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断特殊召唤条件是否满足，即玩家场上怪兽数量大于等于2且有空位
function c31292357.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：判断玩家场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断玩家场上怪兽数量是否大于等于2
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>=2
end
-- 规则层面作用：判断是否可以放置指示物
function c31292357.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x36,1) end
end
-- 规则层面作用：放置指示物并注册伤害变更效果
function c31292357.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:AddCounter(0x36,1) then
		-- 规则层面作用：获取当前连锁ID
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 效果原文内容：给这张卡放置1个娱乐法师指示物（最多3个）。那之后，那个效果让自己受到的伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c31292357.damval)
		e1:SetReset(RESET_CHAIN)
		-- 规则层面作用：将效果注册到全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 规则层面作用：处理伤害变更逻辑，使对应连锁的伤害归零
function c31292357.damval(e,re,val,r,rp,rc)
	-- 规则层面作用：获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 规则层面作用：获取当前连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
-- 规则层面作用：判断指示物数量是否达到3
function c31292357.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x36)==3
end
-- 规则层面作用：设置攻击力和守备力为3300
function c31292357.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果原文内容：这张卡的攻击力·守备力变成3300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(3300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e2)
end
