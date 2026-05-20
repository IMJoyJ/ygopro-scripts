--BOXサー
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。给这张卡放置1个指示物。
-- ②：把有指示物2个以上放置的这张卡送去墓地才能发动。从卡组把1只地属性怪兽特殊召唤。
-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个指示物取除。
function c61156777.initial_effect(c)
	c:EnableCounterPermit(0x34)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。给这张卡放置1个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61156777,0))  --"给这张卡放置1个指示物"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为：这张卡战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetOperation(c61156777.ctop)
	c:RegisterEffect(e1)
	-- ②：把有指示物2个以上放置的这张卡送去墓地才能发动。从卡组把1只地属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61156777,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c61156777.spcost)
	e2:SetTarget(c61156777.sptg)
	e2:SetOperation(c61156777.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个指示物取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c61156777.reptg)
	e3:SetOperation(c61156777.repop)
	c:RegisterEffect(e3)
end
-- 效果处理：若这张卡在场上表侧表示存在，给这张卡放置1个指示物
function c61156777.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x34,1)
	end
end
-- 发动代价：检查自身是否能送去墓地且拥有2个以上的指示物，并将自身送去墓地
function c61156777.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():GetCounter(0x34)>1 end
	-- 作为发动代价将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：地属性且可以特殊召唤的怪兽
function c61156777.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：检查怪兽区域是否有空位，以及卡组是否存在满足条件的地属性怪兽
function c61156777.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（由于自身作为代价送去墓地，空位数量需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足过滤条件的地属性怪兽
		and Duel.IsExistingMatchingCard(c61156777.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只地属性怪兽在自身场上表侧表示特殊召唤
function c61156777.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从卡组选择1只满足条件的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c61156777.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自身场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 代替破坏的条件检查：自身因战斗或效果将被破坏，且可以取除1个指示物，并询问玩家是否使用代替效果
function c61156777.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsCanRemoveCounter(tp,0x34,1,REASON_EFFECT) end
	-- 弹出对话框询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏的效果处理：取除这张卡的1个指示物
function c61156777.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x34,1,REASON_EFFECT)
end
