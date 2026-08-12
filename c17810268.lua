--雲魔物－アシッド・クラウド
-- 效果：
-- 这张卡不会被战斗破坏。这张卡表侧守备表示在场上存在的场合，这张卡破坏。这张卡的召唤成功时，给这张卡放置场上存在的名字带有「云魔物」的怪兽数量的雾指示物。可以把这张卡放置的雾指示物取除2个，场上1张魔法或者陷阱卡破坏。
function c17810268.initial_effect(c)
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
	e2:SetCondition(c17810268.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡的召唤成功时，给这张卡放置场上存在的名字带有「云魔物」的怪兽数量的雾指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17810268,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c17810268.addc)
	c:RegisterEffect(e3)
	-- 可以把这张卡放置的雾指示物取除2个，场上1张魔法或者陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17810268,1))  --"魔陷破坏"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c17810268.descost)
	e4:SetTarget(c17810268.destg)
	e4:SetOperation(c17810268.desop)
	c:RegisterEffect(e4)
end
c17810268.mentioned_counter={
	[0x1019]=true,
}
-- 自我破坏条件：这张卡以表侧守备表示在场上存在。
function c17810268.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤函数：筛选表侧表示存在且名字带有「云魔物」的怪兽。
function c17810268.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 召唤成功时的效果处理：若这张卡仍与该效果关联，则统计双方场上表侧表示的「云魔物」怪兽数量，并给这张卡放置相同数量的雾指示物。
function c17810268.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 统计双方场上表侧表示存在的名字带有「云魔物」的怪兽数量。
		local ct=Duel.GetMatchingGroupCount(c17810268.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		e:GetHandler():AddCounter(0x1019,ct)
	end
end
-- 代价处理：判断能否从这张卡取除2个雾指示物作为代价，能则取除2个雾指示物。
function c17810268.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1019,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1019,2,REASON_COST)
end
-- 过滤函数：筛选魔法卡或陷阱卡。
function c17810268.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标处理：先校验连锁对象是否为场上的魔法·陷阱卡；再判断场上是否存在可作为对象的魔法·陷阱卡；提示选择要破坏的卡，选择场上1张魔法或陷阱卡作为对象，并设置破坏操作信息。
function c17810268.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c17810268.filter(chkc) end
	-- 判断场上是否存在可以成为此效果对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c17810268.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为此效果的对象。
	local g=Duel.SelectTarget(tp,c17810268.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：本次效果将破坏对象中的1张卡（破坏效果分类）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得连锁对象的卡，若该卡仍与效果关联，则以效果原因将其破坏。
function c17810268.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏作为对象的魔法·陷阱卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
