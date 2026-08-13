--巨大戦艦 テトラン
-- 效果：
-- 这张卡召唤时放置3个指示物。这张卡不会被战斗破坏。进行战斗的场合，在伤害步骤结束时取除1个指示物。没有指示物放置的状态进行战斗的场合，伤害步骤结束时这张卡破坏。此外，可以把这张卡的1个指示物取除，破坏场上1张魔法·陷阱卡。这个效果1个回合只能使用1次。
function c44954628.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这张卡召唤时放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44954628,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c44954628.addct)
	e1:SetOperation(c44954628.addc)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 启用巨大战舰系列通用效果：让这张卡在伤害步骤结束时，若持有指示物则取除1个，若无指示物则自身破坏。
	aux.EnableBESRemove(c)
	-- 此外，可以把这张卡的1个指示物取除，破坏场上1张魔法·陷阱卡。这个效果1个回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(44954628,3))  --"魔陷破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c44954628.descost2)
	e5:SetTarget(c44954628.destg2)
	e5:SetOperation(c44954628.desop2)
	c:RegisterEffect(e5)
end
-- 诱发必发效果的发动判定：chk==0 时返回 true 表示满足发动条件，并设置本次效果要放置3个指示物的操作信息。
function c44954628.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：本连锁将处理放置3个0x1f类型的指示物，用于连锁检测和效果提示。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 效果处理时：若这张卡仍与效果关联，则给它放置3个0x1f类型的指示物。
function c44954628.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 作为发动代价：先检查这张卡能否取除1个0x1f指示物；实际发动代价时取除1个指示物。
function c44954628.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 过滤函数：判断一张卡是否为魔法·陷阱卡，用于选择破坏对象。
function c44954628.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 取对象效果的目标处理：检查能否选择场上魔法·陷阱卡，提示玩家选择1张，并将选择目标登记为效果对象，同时设置破坏的操作信息。
function c44954628.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c44954628.filter(chkc) end
	-- 在效果发动时检查场上是否存在至少1张可以作为对象的魔法·陷阱卡，以此决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c44954628.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张满足条件的魔法·陷阱卡作为对象（取对象）。
	local g=Duel.SelectTarget(tp,c44954628.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次连锁将破坏选择的对象 g（1张卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果结算处理：取得对象卡；若对象仍与效果关联，则将其以效果原因破坏。
function c44954628.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡（此处因只取1张对象，所以即唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡 tc。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
