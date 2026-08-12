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
	-- ②：给与自己伤害的魔法·陷阱·怪兽的效果发动时才能发动。给这张卡放置1个娱乐法师指示物（最多3个）。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 发动条件设置为：给与自己伤害的魔法·陷阱·怪兽的效果发动时（玩家受到效果伤害的判定条件）。
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
-- ①效果的特殊召唤条件函数：主要怪兽区有可用空格且场上有2只以上怪兽存在时，这张卡可以从手卡特殊召唤。
function c31292357.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己主要怪兽区还有可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认双方主要怪兽区的怪兽合计有2只以上（场上有怪兽2只以上存在）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>=2
end
-- 发动条件的目标检查：这张卡可以放置1个娱乐法师指示物（未超过3个上限）。
function c31292357.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x36,1) end
end
-- ②效果的处理：给这张卡放置1个娱乐法师指示物，成功后记录那次连锁的连锁ID，并注册一个将该连锁伤害变为0的效果。
function c31292357.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:AddCounter(0x36,1) then
		-- 取得发动给与伤害效果的那次连锁的连锁ID，用于后续识别要归零的伤害。
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		-- 那之后，那个效果让自己受到的伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(c31292357.damval)
		e1:SetReset(RESET_CHAIN)
		-- 将改变伤害数值的效果作为玩家效果注册到全局环境，使其在本连锁内生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害数值判定函数：若伤害由效果引起且属于之前记录的那次连锁，则把伤害变为0，否则维持原伤害值。
function c31292357.damval(e,re,val,r,rp,rc)
	-- 取得当前正在处理的连锁序号。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return val end
	-- 取得当前连锁的连锁ID，以便与记录的ID比对是否为目标连锁。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
-- ③效果的触发条件：这张卡放置的娱乐法师指示物变成3个时。
function c31292357.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x36)==3
end
-- ③效果的处理：将这张卡的攻击力·守备力变成3300，持续到离场或效果被无效为止。
function c31292357.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力·守备力变成3300。
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
