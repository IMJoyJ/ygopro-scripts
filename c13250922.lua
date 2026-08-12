--オオアリクイクイアリ
-- 效果：
-- 这张卡不能通常召唤。把自己场上2张魔法·陷阱卡送去墓地的场合才能特殊召唤。这张卡可以作为攻击的代替而把对方场上1张魔法·陷阱卡破坏。
function c13250922.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上2张魔法·陷阱卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13250922.spcon)
	e2:SetTarget(c13250922.sptg)
	e2:SetOperation(c13250922.spop)
	c:RegisterEffect(e2)
	-- 这张卡可以作为攻击的代替而把对方场上1张魔法·陷阱卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13250922,0))  --"破坏"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c13250922.descost)
	e3:SetTarget(c13250922.destg)
	e3:SetOperation(c13250922.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否满足条件的魔法·陷阱卡
function c13250922.spfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件函数，检查场上是否有2张魔法·陷阱卡满足条件
function c13250922.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c13250922.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查该组卡中是否存在2张满足条件的卡
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤目标函数，用于选择要送去墓地的魔法·陷阱卡
function c13250922.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上满足条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c13250922.spfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从满足条件的卡中选择2张组成子集
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤执行函数，将选中的卡送去墓地
function c13250922.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于判断是否为魔法·陷阱卡
function c13250922.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的费用支付函数，确保该怪兽未宣布过攻击
function c13250922.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 设置该怪兽在本回合不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏效果的目标选择函数，用于选择对方场上的魔法·陷阱卡
function c13250922.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c13250922.filter(chkc) end
	-- 检查对方场上是否存在魔法·陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c13250922.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1张魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c13250922.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁操作为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数，对目标卡进行破坏
function c13250922.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
