--No.59 背反の料理人
-- 效果：
-- 4星怪兽×2
-- ①：自己场上的卡只有这张卡的场合，这张卡不受其他卡的效果影响。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这张卡以外的自己场上的卡全部破坏。那之后，这张卡的攻击力直到回合结束时上升这个效果破坏送去墓地的怪兽数量×300。这个效果在对方回合也能发动。
function c82697249.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只4星怪兽
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己场上的卡只有这张卡的场合，这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c82697249.imcon)
	e1:SetValue(c82697249.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这张卡以外的自己场上的卡全部破坏。那之后，这张卡的攻击力直到回合结束时上升这个效果破坏送去墓地的怪兽数量×300。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82697249,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(c82697249.descost)
	e2:SetTarget(c82697249.destg)
	e2:SetOperation(c82697249.desop)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”编号为59
aux.xyz_number[82697249]=59
-- 定义不受效果影响的条件函数
function c82697249.imcon(e)
	-- 检查自己场上的卡片数量是否为1
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==1
end
-- 定义不受影响的效果过滤器，过滤非自身持有的卡片效果
function c82697249.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 定义效果②的发动代价：取除这张卡的1个超量素材
function c82697249.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果②的发动目标：检查并获取自己场上除这张卡以外的所有卡，并设置破坏的操作信息
function c82697249.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 获取自己场上除这张卡以外的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
	-- 设置效果处理信息：破坏上述获取的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义过滤器：过滤存在于墓地且是怪兽卡的卡片
function c82697249.ctfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 定义效果②的效果处理：破坏自己场上除这张卡以外的所有卡，并根据送去墓地的怪兽数量上升攻击力
function c82697249.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上除这张卡以外的所有卡（若这张卡已离场则不排除）
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 破坏这些卡，并判断是否有卡被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 统计因该效果被破坏并送去墓地的怪兽数量
		local ct=Duel.GetOperatedGroup():FilterCount(c82697249.ctfilter,nil)
		if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 中断效果处理，使后续的攻击力上升处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力直到回合结束时上升这个效果破坏送去墓地的怪兽数量×300。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
