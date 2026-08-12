--アーカナイト・マジシャン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升1000。可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。
function c14553285.initial_effect(c)
	-- 记录这张卡上记载着「爆裂模式」（卡号80280737）的卡名
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制：只有「爆裂模式」的效果才能特殊召唤这张卡
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14553285,0))  --"放置魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c14553285.addct)
	e2:SetOperation(c14553285.addc)
	c:RegisterEffect(e2)
	-- 这张卡放置的魔力指示物每有1个，这张卡的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c14553285.attackup)
	c:RegisterEffect(e3)
	-- 可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14553285,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c14553285.descost)
	e4:SetTarget(c14553285.destg)
	e4:SetOperation(c14553285.desop)
	c:RegisterEffect(e4)
	-- 此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14553285,2))  --"特殊召唤"
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c14553285.spcon)
	e5:SetTarget(c14553285.sptg)
	e5:SetOperation(c14553285.spop)
	c:RegisterEffect(e5)
end
c14553285.assault_name=31924889
c14553285.mentioned_counter={
	[0x1]=true,
}
-- 放置魔力指示物效果的目标函数：无需任何发动条件，并设置操作信息
function c14553285.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将处理放置2个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 效果处理：若这张卡仍与该效果关联，则给这张卡放置2个魔力指示物
function c14553285.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 计算攻击力上升值：这张卡放置的魔力指示物数量×1000
function c14553285.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 破坏效果的代价：检查这张卡能否取除2个魔力指示物，能则取除2个魔力指示物作为发动代价
function c14553285.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 破坏效果的目标函数：确认对方场上存在卡后，设置破坏操作信息
function c14553285.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上至少存在1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的卡组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次连锁将破坏对方场上全部这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：取得对方场上所有的卡并将其全部效果破坏
function c14553285.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的卡组成的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：这张卡被破坏前存在于场上
function c14553285.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 墓地特殊召唤对象的过滤器：卡名为「奥金魔导师」（卡号31924889）且可以特殊召唤
function c14553285.spfilter(c,e,tp)
	return c:IsCode(31924889) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标函数：检查对象合法性及发动条件（有可用怪兽区域且墓地存在可作为对象的「奥金魔导师」）
function c14553285.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14553285.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己的主要怪兽区域存在可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在可以作为效果对象特殊召唤的「奥金魔导师」
		and Duel.IsExistingTarget(c14553285.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地的1只「奥金魔导师」为对象
	local g=Duel.SelectTarget(tp,c14553285.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将特殊召唤作为对象的这1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若作为对象的卡仍与效果关联，则将其攻击表示特殊召唤
function c14553285.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡在自己场上攻击表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
