--ハンニバル・ネクロマンサー
-- 效果：
-- ①：这张卡召唤成功的场合发动。给这张卡放置1个魔力指示物（最多1个）。
-- ②：把这张卡1个魔力指示物取除，以场上1张表侧表示的陷阱卡为对象才能发动。那张表侧表示的陷阱卡破坏。
function c5640330.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,1)
	-- ①：这张卡召唤成功的场合发动。给这张卡放置1个魔力指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5640330,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c5640330.addct)
	e1:SetOperation(c5640330.addc)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个魔力指示物取除，以场上1张表侧表示的陷阱卡为对象才能发动。那张表侧表示的陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5640330,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c5640330.descost)
	e2:SetTarget(c5640330.destg)
	e2:SetOperation(c5640330.desop)
	c:RegisterEffect(e2)
end
c5640330.mentioned_counter={
	[0x1]=true,
}
-- 放置魔力指示物效果的对象检查：此效果必发，无需检查发动条件，设置操作信息声明将给这张卡放置1个魔力指示物。
function c5640330.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：向连锁声明本效果处理时确定要放置1个魔力指示物，用于其他效果的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 效果处理：若这张卡仍与本效果关联，则给这张卡放置1个魔力指示物。
function c5640330.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 破坏效果的代价：检查并取除这张卡的1个魔力指示物作为发动代价。
function c5640330.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 对象筛选条件：表侧表示的陷阱卡。
function c5640330.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsFaceup()
end
-- 破坏效果的对象选择：确认场上存在可作为对象的表侧表示陷阱卡，提示玩家选择，选择1张表侧表示陷阱卡作为对象，并设置破坏的操作信息。
function c5640330.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5640330.filter(chkc) end
	-- 发动条件检查：双方场上是否存在1张可以成为本效果对象的表侧表示陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c5640330.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张场上的表侧表示陷阱卡作为本效果的对象。
	local g=Duel.SelectTarget(tp,c5640330.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：向连锁声明本效果处理时确定要破坏所选的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若其为表侧表示且仍与本效果关联，则以效果将其破坏。
function c5640330.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏那张作为对象的表侧表示陷阱卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
