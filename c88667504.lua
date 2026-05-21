--超整地破砕
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的机械族·地属性怪兽被战斗·效果破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「超接地展开」或者「超信地旋回」在自己的魔法与陷阱区域盖放。
function c88667504.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示的机械族·地属性怪兽被战斗·效果破坏的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88667504,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,88667504)
	e2:SetCondition(c88667504.descon)
	e2:SetTarget(c88667504.destg)
	e2:SetOperation(c88667504.desop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1张「超接地展开」或者「超信地旋回」在自己的魔法与陷阱区域盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88667504,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,88667505)
	-- 将墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c88667504.settg)
	e3:SetOperation(c88667504.setop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的机械族·地属性怪兽因战斗或效果被破坏
function c88667504.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0 and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_EARTH)~=0 and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果①的发动条件：确认是否有符合条件的怪兽被破坏
function c88667504.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88667504.cfilter,1,nil,tp)
end
-- 效果①的对象选择与发动准备
function c88667504.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local exg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exg=e:GetHandler() end
	-- 检查场上是否存在除自身（若未适用）以外的任意卡片作为可选对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exg) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exg)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：破坏作为对象的卡
function c88667504.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤条件：卡组或墓地中可以盖放的「超接地展开」或「超信地旋回」
function c88667504.setfilter(c)
	return c:IsCode(96462121,22866836) and c:IsSSetable()
end
-- 效果②的发动准备
function c88667504.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地中是否存在可盖放的目标卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88667504.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的效果处理：从卡组或墓地选择目标卡盖放到魔陷区
function c88667504.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张目标卡（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88667504.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g)
	end
end
