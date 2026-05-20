--神獣王バルバロス
-- 效果：
-- ①：这张卡可以不用解放作通常召唤。
-- ②：这张卡的①的方法通常召唤的这张卡的原本攻击力变成1900。
-- ③：这张卡也能把3只怪兽解放作召唤。
-- ④：这张卡用这张卡的③的方法召唤成功的场合发动。对方场上的卡全部破坏。
function c78651105.initial_effect(c)
	-- ①：这张卡可以不用解放作通常召唤。②：这张卡的①的方法通常召唤的这张卡的原本攻击力变成1900。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78651105,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c78651105.ntcon)
	e1:SetOperation(c78651105.ntop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ③：这张卡也能把3只怪兽解放作召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78651105,1))  --"解放3只怪兽召唤"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetCondition(c78651105.ttcon)
	e3:SetOperation(c78651105.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF)
	c:RegisterEffect(e3)
	-- ④：这张卡用这张卡的③的方法召唤成功的场合发动。对方场上的卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78651105,2))  --"对方场上的卡全部破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c78651105.descon)
	e4:SetTarget(c78651105.destg)
	e4:SetOperation(c78651105.desop)
	c:RegisterEffect(e4)
end
-- 不用解放作通常召唤的条件判定函数
function c78651105.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定是否不需要解放（minc为0）、自身等级是否在5星以上，以及怪兽区域是否有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 不用解放作通常召唤成功时的处理函数（设置原本攻击力）
function c78651105.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法通常召唤的这张卡的原本攻击力变成1900。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1900)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 解放3只怪兽作通常召唤的条件判定函数
function c78651105.ttcon(e,c,minc)
	if c==nil then return true end
	-- 判定所需解放数量是否不超过3，且场上是否存在3只可解放的怪兽
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 解放3只怪兽作通常召唤时的解放处理函数
function c78651105.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 给玩家发送选择解放怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择3只用于通常召唤的解放怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的怪兽作为召唤素材解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的发动条件判定：判定是否是通过解放3只怪兽的方法召唤成功
function c78651105.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+SUMMON_VALUE_SELF
end
-- 破坏效果的发动准备与目标确认函数
function c78651105.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有卡片
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理的操作信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果的执行处理函数
function c78651105.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏选中的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
