--レプティレス・ヴァースキ
-- 效果：
-- 这张卡不能通常召唤。把自己·对方场上2只攻击力0的怪兽解放的场合才能特殊召唤。
-- ①：「爬虫妖女·和修吉」在场上只能有1只表侧表示存在。
-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。
function c16886617.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,16886617)
	-- ①：「爬虫妖女·和修吉」在场上只能有1只表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。把自己·对方场上2只攻击力0的怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c16886617.spcon)
	e2:SetTarget(c16886617.sptg)
	e2:SetOperation(c16886617.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16886617,0))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c16886617.destg)
	e5:SetOperation(c16886617.desop)
	c:RegisterEffect(e5)
end
-- 过滤函数，返回满足条件的怪兽：表侧表示、攻击力为0、可因特殊召唤而解放
function c16886617.rfilter(c)
	return c:IsFaceup() and c:IsAttack(0) and c:IsReleasable(REASON_SPSUMMON)
end
-- 特殊召唤条件函数，检查场上是否存在满足条件的2只怪兽
function c16886617.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足条件的怪兽组（场上所有怪兽）
	local rg=Duel.GetMatchingGroup(c16886617.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查该组怪兽中是否存在满足条件的2只怪兽
	return rg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤目标函数，选择满足条件的2只怪兽进行解放
function c16886617.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组（场上所有怪兽）
	local rg=Duel.GetMatchingGroup(c16886617.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从满足条件的怪兽中选择2只进行解放
	local sg=rg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数，将选中的怪兽解放
function c16886617.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤原因为由解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏效果过滤函数，返回满足条件的怪兽：表侧表示
function c16886617.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果目标函数，选择对方场上1只表侧表示怪兽作为目标
function c16886617.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c16886617.desfilter(chkc) end
	-- 检查是否存在满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(c16886617.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c16886617.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，确定要破坏的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果操作函数，对目标怪兽进行破坏
function c16886617.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因为由破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
