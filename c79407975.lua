--究極宝玉神 レインボー・ダーク・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把暗属性怪兽7种类各1只除外的场合才能特殊召唤。
-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把这张卡以外的暗属性怪兽全部除外才能发动。这张卡的攻击力上升除外数量×500。
function c79407975.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己墓地把暗属性怪兽7种类各1只除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c79407975.spcon)
	e2:SetTarget(c79407975.sptg)
	e2:SetOperation(c79407975.spop)
	c:RegisterEffect(e2)
	-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把这张卡以外的暗属性怪兽全部除外才能发动。这张卡的攻击力上升除外数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(79407975,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c79407975.atkcost)
	e3:SetOperation(c79407975.atkop)
	c:RegisterEffect(e3)
end
-- 过滤自身特殊召唤所需除外的暗属性怪兽的条件（暗属性且可以作为代价除外）
function c79407975.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 自身特殊召唤规则的条件判断（检查怪兽区域空位以及墓地暗属性怪兽是否达到7种类）
function c79407975.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取自己墓地所有满足条件的暗属性怪兽
	local g=Duel.GetMatchingGroup(c79407975.spfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>=7
end
-- 自身特殊召唤规则的卡片选择处理（从墓地选择7种类各1只暗属性怪兽）
function c79407975.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地所有满足条件的暗属性怪兽
	local g=Duel.GetMatchingGroup(c79407975.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置卡片组检查函数，确保后续选择的卡片卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从墓地中选择7张卡名不同的暗属性怪兽
	local sg=g:SelectSubGroup(tp,aux.TRUE,true,7,7)
	-- 重置卡片组检查函数，避免影响后续的其他选择逻辑
	aux.GCheckAdditional=nil
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤规则的执行操作（将选中的7张卡名不同的暗属性怪兽除外）
function c79407975.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_SPSUMMON)
	rg:DeleteGroup()
end
-- 过滤①效果需要除外的暗属性怪兽（自己墓地或自己场上表侧表示的暗属性怪兽）
function c79407975.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- ①效果的发动代价处理（将自己墓地以及自己场上表侧表示的这张卡以外的暗属性怪兽全部除外，并记录除外数量）
function c79407975.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地以及自己场上表侧表示的这张卡以外的所有暗属性怪兽
	local g=Duel.GetMatchingGroup(c79407975.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return g:GetCount()>0 and g:FilterCount(Card.IsAbleToRemoveAsCost,nil)==g:GetCount() end
	e:SetLabel(g:GetCount())
	-- 将这些怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的效果处理（使这张卡的攻击力上升除外数量×500）
function c79407975.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升除外数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
