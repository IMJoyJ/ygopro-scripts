--雲魔物－キロスタス
-- 效果：
-- 这张卡不会被战斗破坏。这张卡表侧守备表示在场上存在的场合，这张卡破坏。这张卡的召唤成功时，给这张卡放置场上存在的名字带有「云魔物」的怪兽数量的雾指示物。可以把这张卡放置的雾指示物取除2个，场上1只怪兽破坏。
function c43318266.initial_effect(c)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c43318266.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡的召唤成功时，给这张卡放置场上存在的名字带有「云魔物」的怪兽数量的雾指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43318266,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c43318266.addc)
	c:RegisterEffect(e3)
	-- 可以把这张卡放置的雾指示物取除2个，场上1只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(43318266,1))  --"怪兽破坏"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c43318266.descost)
	e4:SetTarget(c43318266.destg)
	e4:SetOperation(c43318266.desop)
	c:RegisterEffect(e4)
end
c43318266.mentioned_counter={
	[0x1019]=true,
}
-- 自我破坏的发动条件：这张卡在场上表侧守备表示存在。
function c43318266.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤器：选取场上表侧表示存在的名字带有「云魔物」的怪兽。
function c43318266.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 效果处理：这张卡仍与效果关联时，统计双方场上表侧表示的「云魔物」怪兽数量，并给这张卡放置该数量的雾指示物。
function c43318266.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 统计双方主要怪兽区表侧表示存在的名字带有「云魔物」的怪兽数量。
		local ct=Duel.GetMatchingGroupCount(c43318266.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		e:GetHandler():AddCounter(0x1019,ct)
	end
end
-- 代价：确认并能从这张卡取除2个雾指示物作为发动代价。
function c43318266.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1019,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1019,2,REASON_COST)
end
-- 取对象：确认场上存在可作为对象的怪兽，选择场上1只怪兽作为破坏对象，并设置破坏效果的操作信息。
function c43318266.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件检查：场上存在至少1只可以成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方主要怪兽区的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将破坏作为对象的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与效果关联则将其破坏。
function c43318266.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
