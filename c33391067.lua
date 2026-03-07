--呪詛返しのヒトガタ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：给与自己伤害的怪兽的效果发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
-- ②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己场上盖放。
function c33391067.initial_effect(c)
	-- ①：给与自己伤害的怪兽的效果发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c33391067.condition)
	e1:SetOperation(c33391067.refop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己受到战斗伤害时才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,33391067)
	e2:SetCondition(c33391067.setcon)
	e2:SetTarget(c33391067.settg)
	e2:SetOperation(c33391067.setop)
	c:RegisterEffect(e2)
end
-- 判断连锁是否由对方怪兽效果引起并造成我方伤害
function c33391067.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否由对方怪兽效果引起并造成我方伤害
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 将反射伤害效果注册给对方玩家，使对方承受我方受到的伤害
function c33391067.refop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 创建并注册一个反射伤害效果，使对方承受我方受到的伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c33391067.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册到指定玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前连锁是否为指定连锁ID，用于确保只反射特定连锁的伤害
function c33391067.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
-- 判断造成战斗伤害的玩家是否为我方
function c33391067.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 设置操作信息，表示将卡片从墓地盖放到场上
function c33391067.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示将卡片从墓地盖放到场上
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行将卡片盖放到场上的操作
function c33391067.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片盖放到场上
		Duel.SSet(tp,c)
	end
end
