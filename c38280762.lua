--紫炎の老中 エニシ
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
function c38280762.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件值设为 false，表示这张卡不能通过其他效果特殊召唤，只能通过自身注册的特殊召唤手续出场。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c38280762.spcon)
	e2:SetTarget(c38280762.sptg)
	e2:SetOperation(c38280762.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38280762,0))  --"表侧表示存在的1只怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c38280762.descost)
	e3:SetTarget(c38280762.destg)
	e3:SetOperation(c38280762.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤手续的素材过滤器：要求是卡名包含「六武众」、属于怪兽卡且可以作为cost从墓地除外。
function c38280762.spfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤手续的条件：自己场上有可用的怪兽区域，且自己墓地存在至少2只满足 spfilter 的「六武众」怪兽。
function c38280762.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在空余的怪兽区域，以容纳这张卡特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少2张满足 spfilter 条件的「六武众」怪兽，作为特殊召唤的除外代价。
		and Duel.IsExistingMatchingCard(c38280762.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤手续的选择阶段：从通过过滤的墓地「六武众」怪兽中选取2张作为除外代价；选中后存入效果标签并继续手续。
function c38280762.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足 spfilter 条件的「六武众」怪兽，构成候选集合供选择。
	local g=Duel.GetMatchingGroup(c38280762.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 显示选择提示，提示玩家选择要除外的「六武众」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的结算：将先前选定的2张墓地「六武众」怪兽从游戏中除外，完成特殊召唤所需的代价。
function c38280762.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以表侧表示从游戏中除外选中的「六武众」怪兽，作为这次特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 起动效果的发动代价：先确认这张卡本回合没有攻击宣言过；然后给自己附加一个本回合不能攻击宣言的誓约效果。
function c38280762.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏效果的对象过滤器：选择场上表侧表示的怪兽。
function c38280762.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果的发动处理：选择场上表侧表示存在的1只怪兽（取对象），并设置破坏的操作信息。
function c38280762.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38280762.desfilter(chkc) end
	-- 发动时确认场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1只表侧表示怪兽作为这张卡效果的对象，并记录到当前连锁中。
	local g=Duel.SelectTarget(tp,c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果类别为破坏，预定破坏1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的结算：取得对象怪兽，确认其仍表侧表示且与效果关联后，将其破坏。
function c38280762.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一个对象（即被选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
