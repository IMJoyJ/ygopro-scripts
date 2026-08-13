--M・HERO アシッド
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。对方场上的魔法·陷阱卡全部破坏，对方场上的全部怪兽的攻击力下降300。
function c29095552.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为aux.MaskChangeLimit，即仅允许通过「假面变化」的效果来特殊召唤这张卡。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合发动。对方场上的魔法·陷阱卡全部破坏，对方场上的全部怪兽的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29095552,0))  --"魔陷破坏"
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c29095552.destg)
	e2:SetOperation(c29095552.desop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：判断卡片是否为魔法·陷阱卡（包含通常/永续/装备/场地/速攻魔法及通常/永续/反击陷阱等类型）。
function c29095552.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理：无需选择对象，获取对方场上所有魔法·陷阱卡并登记为本次破坏的对象，同时设置操作信息。
function c29095552.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前对方场上所有魔法·陷阱卡的集合（作为不取对象的潜在破坏对象）。
	local g=Duel.GetMatchingGroup(c29095552.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：声明将破坏上述集合中的卡，数量为集合卡数；该信息用于连锁响应等规则判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：破坏对方场上全部魔法·陷阱卡；若成功破坏，再对对方场上全部表侧表示怪兽施加攻击力下降300。
function c29095552.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时重新获取对方场上当前的魔法·陷阱卡集合（因为从发动到处理期间卡片可能发生变化）。
	local g=Duel.GetMatchingGroup(c29095552.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏该集合中的所有卡片；若实际破坏了至少一张卡，则继续执行后续攻击力下降处理。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取对方场上所有表侧表示怪兽的集合，作为攻击力下降的适用对象。
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=mg:GetFirst()
		while tc do
			-- 对方场上的全部怪兽的攻击力下降300。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=mg:GetNext()
		end
	end
end
