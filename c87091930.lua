--レイダーズ・アンブレイカブル・マインド
-- 效果：
-- 这个卡名在规则上也当作「幻影骑士团」卡、「急袭猛禽」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己作以暗属性超量怪兽为素材的超量召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：魔法与陷阱区域的表侧表示的这张卡被效果破坏的场合才能发动。从自己的卡组·墓地选1张「升阶魔法」魔法卡在自己场上盖放。
function c87091930.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己作以暗属性超量怪兽为素材的超量召唤成功的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(87091930,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,87091930)
	e2:SetCondition(c87091930.descon)
	e2:SetTarget(c87091930.destg)
	e2:SetOperation(c87091930.desop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被效果破坏的场合才能发动。从自己的卡组·墓地选1张「升阶魔法」魔法卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87091930,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,87091931)
	e3:SetCondition(c87091930.ssetcon)
	e3:SetTarget(c87091930.ssettg)
	e3:SetOperation(c87091930.ssetop)
	c:RegisterEffect(e3)
end
-- 过滤条件：是否为暗属性超量怪兽
function c87091930.descfilter2(c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：检查是否为自己进行的以暗属性超量怪兽为素材的超量召唤
function c87091930.descfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
		and c:GetMaterial():IsExists(c87091930.descfilter2,1,nil)
end
-- 效果①发动条件：检查特殊召唤的怪兽中是否存在满足条件的自己超量召唤的怪兽
function c87091930.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87091930.descfilter,1,nil,tp)
end
-- 效果①的发动准备：检查并选择场上1张卡作为破坏对象，并设置破坏的操作信息
function c87091930.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local exg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exg=e:GetHandler() end
	-- 检查场上是否存在至少1张可以作为对象的卡（若此卡自身未准备就绪，则排除此卡自身）
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exg) end
	-- 给玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exg)
	-- 设置操作信息：包含破坏分类，数量为1，目标为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的卡破坏
function c87091930.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②发动条件：检查这张卡之前是否在魔法与陷阱区域表侧表示存在，且因效果被破坏
function c87091930.ssetcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
		and e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：卡组或墓地中可盖放的「升阶魔法」魔法卡
function c87091930.ssetfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x95) and c:IsSSetable()
end
-- 效果②的发动准备：检查自己的卡组或墓地是否存在可以盖放的「升阶魔法」魔法卡
function c87091930.ssettg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张满足条件的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87091930.ssetfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
end
-- 效果②的效果处理：从自己的卡组或墓地选择1张「升阶魔法」魔法卡在自己场上盖放
function c87091930.ssetop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己的卡组或墓地选择1张满足条件且不受「王家长眠之谷」影响的「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c87091930.ssetfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
