--外神アザトート
-- 效果：
-- 5星怪兽×3
-- 这张卡也能在自己场上的「外神」超量怪兽上面把这张卡重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：这张卡超量召唤成功的回合，对方不能把怪兽的效果发动。
-- ②：这张卡有融合·同调·超量怪兽全部在作为超量素材的场合，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏。
function c34945480.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,3,c34945480.ovfilter,aux.Stringid(34945480,1))  --"是否在自己场上的「外神」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤成功的回合，对方不能把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c34945480.sumcon)
	e2:SetOperation(c34945480.sumsuc)
	c:RegisterEffect(e2)
	-- ②：这张卡有融合·同调·超量怪兽全部在作为超量素材的场合，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34945480,0))  --"对方场上的卡全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c34945480.condition)
	e3:SetCost(c34945480.cost)
	e3:SetTarget(c34945480.target)
	e3:SetOperation(c34945480.operation)
	c:RegisterEffect(e3)
end
-- 辅助超量召唤手续的筛选条件：除通常的5星怪兽×3叠放外，也允许以自己场上表侧表示且属于「外神」超量怪兽的卡片作为重叠对象，实现‘这张卡也能在自己场上的「外神」超量怪兽上面把这张卡重叠来超量召唤’。
function c34945480.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb6) and c:IsType(TYPE_XYZ)
end
-- ①效果的触发条件：仅当这张卡以超量召唤（SUMMON_TYPE_XYZ）方式特殊召唤成功时返回true，用于限定“超量召唤成功的回合”。
function c34945480.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 超量召唤成功后的处理：创建一个持续到结束阶段、影响对方玩家的领域效果，令对方不能发动效果，并通过actlimit将禁发范围限定为怪兽效果，从而适用①效果。
function c34945480.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡超量召唤成功的回合，对方不能把怪兽的效果发动。②：这张卡有融合·同调·超量怪兽全部在作为超量素材的场合，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c34945480.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的禁止效果e1注册给当前玩家tp，使其在场上生效，开始禁止对方发动怪兽效果。
	Duel.RegisterEffect(e1,tp)
end
-- actlimit是禁止效果的判定函数：当尝试发动的效果为怪兽效果（re:IsActiveType(TYPE_MONSTER)）时返回true，即该效果不能发动；非怪兽效果不受影响。
function c34945480.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动条件：检查这张卡的超量素材中是否同时存在融合怪兽、同调怪兽和超量怪兽各至少1只，三者齐备时才允许发动。
function c34945480.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	return g:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
		and g:IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- ②效果的发动代价：取除这张卡的1个超量素材。chk==0时先确认是否有素材可取；发动时以REASON_COST实际取除1个超量素材。
function c34945480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果发动时的目标处理：先确认对方场上有卡，再获取对方场上全部卡并写入连锁操作信息，宣告这些卡将被破坏（不取对象）。
function c34945480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：chk==0时确认对方场上是否存在至少1张卡，满足则可发动；仅作为条件判断，不取对象。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上当前存在的全部卡片（aux.TRUE恒真，即全部满足条件），组成集合g，作为待破坏卡片的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将连锁操作信息设置为“破坏对方场上全部卡片”（数量为g的卡片数），分类为CATEGORY_DESTROY，供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的实际操作：重新获取对方场上全部卡片，然后将其全部破坏，破坏原因为效果（REASON_EFFECT）。
function c34945480.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段重新获取对方场上的全部卡片，以此时实际存在的卡片为准。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将获取到的对方场上卡片全部破坏，破坏原因为效果（REASON_EFFECT）。
	Duel.Destroy(g,REASON_EFFECT)
end
