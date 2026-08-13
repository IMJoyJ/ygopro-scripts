--サイバー・エルタニン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×500。
-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的场上的表侧表示怪兽全部送去墓地。
function c33093439.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为false，使这张卡不能通过其他效果或方式特殊召唤，只能通过自身的特殊召唤手续进行特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外的场合才能特殊召唤；①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c33093439.spcon)
	e2:SetOperation(c33093439.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的场上的表侧表示怪兽全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33093439,0))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c33093439.target)
	e3:SetOperation(c33093439.operation)
	c:RegisterEffect(e3)
end
-- 筛选符合条件的怪兽：机械族·光属性、可作为除外代价；且在场上时必须为表侧表示（墓地中的不要求表示形式）。
function c33093439.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 特殊召唤条件判定：若c为nil则视为规则询问直接通过；否则检查自己场上是否存在符合条件的表侧表示机械族·光属性怪兽，或自己墓地存在符合条件的怪兽且自己场上有空余怪兽区域，满足其一即可进行特殊召唤。
function c33093439.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1张满足筛选条件的表侧表示怪兽（机械族·光属性且可作为除外代价）。
	return Duel.IsExistingMatchingCard(c33093439.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 或者，若自己墓地存在符合条件的机械族·光属性怪兽，且自己场上有空余怪兽区域，也可以作为从墓地除外进行特殊召唤的条件。
		or (Duel.IsExistingMatchingCard(c33093439.cfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- 特殊召唤处理：选取自己场上表侧表示及墓地中所有符合条件的机械族·光属性怪兽，将它们全部除外，并使这张卡的攻击力·守备力变为除外数量×500。
function c33093439.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取自己场上表侧表示和墓地中所有满足筛选条件的机械族·光属性怪兽，作为本次特殊召唤要除外的对象组。
	local g=Duel.GetMatchingGroup(c33093439.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 将选中的所有条件怪兽以表侧表示除外，除外原因记为这次特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	-- ①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(g:GetCount()*500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- ②效果发动时点：由于是必发效果，chk==0时直接返回true允许发动；同时取得场上除本卡外的所有表侧表示怪兽，并登记为即将送去墓地的操作信息。
function c33093439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除这张卡以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 登记本次效果将上述怪兽送去墓地的操作信息，数量为取得的怪兽数量，用于时点或连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ②效果处理：实际获得场上除这张卡以外的全部表侧表示怪兽，并将其全部送去墓地。
function c33093439.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有表侧表示怪兽（通过aux.ExceptThisCard(e)排除效果持有者自身）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将获得的全部怪兽以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
