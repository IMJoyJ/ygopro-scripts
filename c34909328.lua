--ライゼオル・デッドネーダー
-- 效果：
-- 4星「雷火沸动」怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把自己墓地1只怪兽作为这张卡的超量素材。
-- ②：对方把卡的效果发动时，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己场上的超量怪兽被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
local s,id,o=GetID()
-- 定义卡片的初始化函数：为卡片添加超量召唤手续，并注册①、②、③三个效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用等级4的「雷火沸动」怪兽2只以上（最多99只）作为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1be),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。把自己墓地1只怪兽作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：自己场上的超量怪兽被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.desreptg)
	e3:SetValue(s.desrepval)
	e3:SetOperation(s.desrepop)
	c:RegisterEffect(e3)
end
-- 定义墓地怪兽能否作为超量素材的过滤条件：必须是怪兽、可以作为超量素材，且不免疫该效果。
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- ①效果发动条件判定：本卡为超量怪兽，且自己墓地存在满足条件的怪兽。
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在至少1只满足s.mtfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，声明该效果涉及墓地卡片离开墓地，用于王家长眠之谷等卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
-- 效果处理：若本卡仍与效果关联，则从自己墓地选择1只满足条件且不受王家长眠之谷影响的怪兽，叠放在本卡下方作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家发送选择超量素材的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从自己墓地选择1只满足条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
	if g:GetCount()>0 then
		-- 将选择的怪兽作为超量素材叠放在本卡下方。
		Duel.Overlay(c,g)
	end
end
-- ②效果的发动条件：由对方玩家发动了卡的效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- ②效果的发动代价：从本卡取除1个超量素材。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标处理：选择场上1张卡作为对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查双方场上是否存在至少1张可以作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择要破坏的卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，声明将破坏选择的对象卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得效果对象，若对象仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理中作为对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其以效果破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 定义可被代替破坏的怪兽条件：本方场上的表侧超量怪兽，且即将因战斗或效果被破坏（且不是由代替破坏产生的原因）。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ③效果的发动判定：存在因战斗或效果将要被破坏的本方超量怪兽，且这张卡有可去除的超量素材。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 弹出是否发动代替破坏效果的确认提示。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为代替破坏效果的判断函数：返回true表示允许用这张卡代替即将被破坏的怪兽。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ③效果处理：取除本卡1个超量素材，并展示本卡的卡片动画。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 向双方玩家展示本卡的卡片动画，提示代替破坏效果的发动。
	Duel.Hint(HINT_CARD,0,id)
end
