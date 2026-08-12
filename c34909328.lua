--ライゼオル・デッドネーダー
-- 效果：
-- 4星「雷火沸动」怪兽×2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把自己墓地1只怪兽作为这张卡的超量素材。
-- ②：对方把卡的效果发动时，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：自己场上的超量怪兽被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤程序、启用特殊召唤限制并注册三个效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，要求满足条件的4星「雷火沸动」怪兽2只以上作为叠放素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1be),4,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 效果①：特殊召唤成功时才能发动，将自己墓地1只怪兽作为超量素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	-- 效果②：对方发动卡的效果时，取除1个超量素材，破坏场上1张卡
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
	-- 效果③：自己场上的超量怪兽被战斗·效果破坏时，可以代替破坏取除1个超量素材
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
-- 过滤函数，用于筛选可作为超量素材的怪兽（必须是怪兽卡、可叠放且不受效果影响）
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果①的发动条件判断函数，检查是否满足XYZ怪兽类型并存在可选墓地怪兽
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 继续检查是否存在满足条件的墓地怪兽
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示将要从墓地移除1张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
-- 效果①的处理函数，选择并叠放墓地怪兽作为超量素材
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从墓地选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
	if g:GetCount()>0 then
		-- 将选中的卡叠放至该卡上
		Duel.Overlay(c,g)
	end
end
-- 效果②的发动条件判断函数，检查是否为对方发动效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②的费用支付函数，扣除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的目标选择函数，选择场上1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否存在场上1张卡可作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理函数，破坏选中的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡存在则将其破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 代替破坏的过滤函数，筛选自己场上的XYZ怪兽且因战斗或效果被破坏
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件判断函数，检查是否有满足条件的破坏对象并确认该卡可取除超量素材
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，取除1个超量素材并提示发动
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	-- 提示发动该卡的动画效果
	Duel.Hint(HINT_CARD,0,id)
end
