--Emハットトリッカー
-- 效果：
-- ①：场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。给这张卡放置1个娱乐法师指示物（最多3个）。那之后，那个效果让自己受到的伤害变成0。
-- ③：这张卡有娱乐法师指示物被放置，那些娱乐法师指示物变成3个时，这张卡的攻击力·守备力变成3300。
function c31292357.initial_effect(c)
	c:EnableCounterPermit(0x36)
	c:SetCounterLimit(0x36,3)
	-- ①：场上有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c31292357.spcon)
	c:RegisterEffect(e1)
	-- ②：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。给这张卡放置1个娱乐法师指示物（最多3个）。那之后，那个效果让自己受到的伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 判断连锁效果是否为对玩家造成伤害的效果
	e2:SetCondition(aux.damcon1)
	e2:SetTarget(c31292357.cttg)
	e2:SetOperation(c31292357.ctop)
	c:RegisterEffect(e2)
	-- ③：这张卡有娱乐法师指示物被放置，那些娱乐法师指示物变成3个时，这张卡的攻击力·守备力变成3300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADD_COUNTER+0x36)
	e3:SetCondition(c31292357.atkcon)
	e3:SetOperation(c31292357.atkop)
	c:RegisterEffect(e3)
end
c31292357.mentioned_counter={
	[0x36]=true,
}
-- 满足特殊召唤条件：场上怪兽数量不少于2只且有空余怪兽区域
function c31292357.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上的怪兽数量是否不少于2只
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>=2
end
-- 判断是否可以为卡片放置指示物
function c31292357.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x36,1) end
end
-- 为卡片放置1个指示物，并注册一个改变伤害值的效果
function c31292357.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:AddCounter(0x36,1) then
		-- 获取当前连锁的唯一标识ID
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 将改变伤害值的效果注册给对应玩家
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c31292357.damval)
		e1:SetReset(RESET_CHAIN)
		-- 将效果注册到全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为同一连锁，若是则将伤害值设为0
function c31292357.damval(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
-- 判断指示物数量是否达到3个
function c31292357.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x36)==3
end
-- 将卡片攻击力和守备力设置为3300
function c31292357.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将卡片攻击力设置为3300
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
