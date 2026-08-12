--至天の魔王ミッシング・バロウズ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以从自己墓地把卡3种类（怪兽·魔法·陷阱）各1张除外，从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。把1只怪兽和2张魔法·陷阱卡从对方的场上·墓地除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤的规则效果和特殊召唤成功时的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡可以从自己墓地把卡3种类（怪兽·魔法·陷阱）各1张除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手牌特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合才能发动。把1只怪兽和2张魔法·陷阱卡从对方的场上·墓地除外。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤自身特殊召唤所需除外代价的卡片（必须是可以作为代价除外的卡）。
function s.sprfilter(c)
	return c:IsAbleToRemoveAsCost()
end
-- 检查选取的卡片组是否满足特殊召唤条件：腾出怪兽区域，且怪兽、魔法、陷阱卡各刚好有1张。
function s.gcheck(g,tp)
	-- 检查将选取的卡片除外后，自己场上是否有可用于特殊召唤该怪兽的空余怪兽区域。
	return Duel.GetMZoneCount(tp,g)>0
		and g:FilterCount(Card.IsType,nil,TYPE_MONSTER)==1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)==1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)==1
end
-- 特殊召唤规则的条件判断函数，检查自己墓地是否存在满足条件的3张卡（怪兽、魔法、陷阱各1张）。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有可以作为代价除外的卡片。
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	return g:CheckSubGroup(s.gcheck,3,3,tp)
end
-- 特殊召唤规则的卡片选择函数，让玩家从墓地选择满足条件的3张卡并暂存。
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可以作为代价除外的卡片。
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，将选定的3张卡除外以完成特殊召唤。
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的3张卡作为特殊召唤的代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
-- 效果②的发动条件：此卡必须是从手卡特殊召唤成功的场合。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 过滤可以被效果除外的卡片。
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 检查选取的卡片组中是否包含1只怪兽，且其余卡片中包含2张魔法或陷阱卡。
function s.rmfgilter(c,g)
	return c:IsType(TYPE_MONSTER) and g:IsExists(Card.IsType,2,c,TYPE_SPELL+TYPE_TRAP)
end
-- 检查选取的3张卡是否满足“1只怪兽和2张魔法·陷阱卡”的组合。
function s.rmcheck(g)
	return g:IsExists(s.rmfgilter,1,nil,g)
end
-- 效果②的发动准备与可行性检查，设置除外的操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上及对方墓地中所有可以被除外的卡片。
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	if chk==0 then return g:CheckSubGroup(s.rmcheck,3,3,tp) end
	-- 设置效果处理信息，表示将从对方的场上或墓地除外卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE+LOCATION_ONFIELD)
end
-- 效果②的效果处理函数，让玩家从对方场上·墓地选择1只怪兽和2张魔陷除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上及对方墓地中所有可以被除外的卡片（适用王家之谷的过滤）。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.rmfilter),tp,0,LOCATION_GRAVE+LOCATION_ONFIELD,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rmcheck,false,3,3,tp)
	if sg then
		-- 选中对方场上的卡片时，在场上显式框选这些卡片以向双方玩家展示。
		Duel.HintSelection(sg)
		-- 将选定的3张卡因效果表侧表示除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
