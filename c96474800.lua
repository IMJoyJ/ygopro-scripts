--マジック・ディフレクター
-- 效果：
-- 这个回合，场上的装备·场地·永续·速攻魔法卡的效果无效。
function c96474800.initial_effect(c)
	-- 这个回合，场上的装备·场地·永续·速攻魔法卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c96474800.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：在全局注册使场上特定类型魔法卡无效的永续效果，以及在连锁处理时使特定类型魔法卡效果无效的持续效果
function c96474800.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，场上的装备·场地·永续·速攻魔法卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c96474800.distg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局注册使场上特定类型魔法卡无效的永续效果
	Duel.RegisterEffect(e1,tp)
	-- 这个回合，场上的装备·场地·永续·速攻魔法卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c96474800.disop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向全局注册在连锁处理时使特定类型魔法卡效果无效的持续效果
	Duel.RegisterEffect(e2,tp)
end
-- 确定无效的目标为场上的装备、场地、永续、速攻魔法卡
function c96474800.distg(e,c)
	local tpe=c:GetType()
	return bit.band(tpe,TYPE_SPELL)~=0 and bit.band(tpe,TYPE_EQUIP+TYPE_FIELD+TYPE_CONTINUOUS+TYPE_QUICKPLAY)~=0
end
-- 在连锁处理时，若发动效果的卡是场上的装备、场地、永续、速攻魔法卡，则将其效果无效
function c96474800.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local tpe=re:GetActiveType()
	if bit.band(tl,LOCATION_SZONE)~=0 and bit.band(tpe,TYPE_SPELL)~=0 and bit.band(tpe,TYPE_EQUIP+TYPE_FIELD+TYPE_CONTINUOUS+TYPE_QUICKPLAY)~=0 then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
