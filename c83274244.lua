--ドドドウォリアー
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1800。此外，这张卡攻击的场合，直到伤害步骤结束时对方墓地发动的效果无效化。
function c83274244.initial_effect(c)
	-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83274244,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c83274244.ntcon)
	e1:SetOperation(c83274244.ntop)
	c:RegisterEffect(e1)
	-- 此外，这张卡攻击的场合，直到伤害步骤结束时对方墓地发动的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c83274244.negcon)
	e2:SetOperation(c83274244.negop)
	c:RegisterEffect(e2)
end
-- 不用解放召唤的条件函数
function c83274244.ntcon(e,c,minc)
	if c==nil then return true end
	-- 要求解放怪兽数量为0、自身等级在5星以上，且己方场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 不用解放召唤成功时的效果处理函数
function c83274244.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡的原本攻击力变成1800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1800)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 无效化效果的发动条件函数
function c83274244.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击的怪兽是否是自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 无效化效果的操作函数
function c83274244.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if ep~=tp and loc==LOCATION_GRAVE then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
