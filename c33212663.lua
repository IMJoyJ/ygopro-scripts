--アークネメシス・エスカトス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把3只种族不同的怪兽除外的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不会被效果破坏。
-- ②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
function c33212663.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33212663.sprcon)
	e1:SetTarget(c33212663.sprtg)
	e1:SetOperation(c33212663.sprop)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33212663,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,33212663)
	e3:SetTarget(c33212663.destg)
	e3:SetOperation(c33212663.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否可以作为特殊召唤的除外代价的怪兽（场上正面表示或墓地的怪兽且可除外）
function c33212663.sprfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 子函数，用于判断所选的3只怪兽是否满足种族不同且有足够怪兽区的条件
function c33212663.fselect(g,tp)
	-- 判断所选的怪兽组是否满足种族不同且有足够怪兽区的条件
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetRace)==#g
end
-- 判断是否满足特殊召唤条件：从自己墓地以及自己场上的表侧表示怪兽之中把3只种族不同的怪兽除外
function c33212663.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上和墓地中所有满足条件的怪兽（正面表示或在墓地）
	local rg=Duel.GetMatchingGroup(c33212663.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return rg:CheckSubGroup(c33212663.fselect,3,3,tp)
end
-- 选择满足条件的3只怪兽并设置为特殊召唤的除外对象
function c33212663.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上和墓地中所有满足条件的怪兽（正面表示或在墓地）
	local rg=Duel.GetMatchingGroup(c33212663.sprfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectSubGroup(tp,c33212663.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作
function c33212663.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的怪兽组以特殊召唤的方式除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数，用于判断是否为正面表示且种族为指定种族的怪兽
function c33212663.desfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
-- 设置效果目标：选择要宣言的种族并准备破坏对应种族的怪兽
function c33212663.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否场上存在正面表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local race=0
	while tc do
		race=race|tc:GetRace()
		tc=g:GetNext()
	end
	-- 提示玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从可选种族中宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,race)
	e:SetLabel(rc)
	-- 获取场上所有正面表示且种族为指定种族的怪兽
	local dg=Duel.GetMatchingGroup(c33212663.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,rc)
	-- 设置操作信息：准备破坏指定种族的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 执行效果操作：破坏指定种族的怪兽并设置禁止该种族怪兽特殊召唤的效果
function c33212663.desop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 获取场上所有正面表示且种族为指定种族的怪兽
	local dg=Duel.GetMatchingGroup(c33212663.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,race)
	if dg:GetCount()>0 then
		-- 以效果原因破坏指定的怪兽
		Duel.Destroy(dg,REASON_EFFECT)
	end
	-- ②：宣言场上的怪兽1个种族才能发动。场上的宣言种族的怪兽全部破坏。直到下个回合的结束时，双方不能把宣言的种族的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetLabel(race)
	e1:SetTarget(c33212663.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将禁止特殊召唤的效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果目标：禁止指定种族的怪兽特殊召唤
function c33212663.splimit(e,c)
	return c:IsRace(e:GetLabel())
end
