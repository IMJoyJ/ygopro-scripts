--剛鬼ザ・パワーロード・オーガ
-- 效果：
-- 战士族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡以外的自己场上的连接怪兽的连接标记合计×200。
-- ②：连接召唤的这张卡不受其他卡的效果影响。
-- ③：把自己场上1只「刚鬼」连接怪兽解放，以最多有那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
function c11516241.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只以上的战士族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡以外的自己场上的连接怪兽的连接标记合计×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c11516241.atkval)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡不受其他卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c11516241.imcon)
	e2:SetValue(c11516241.efilter)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：把自己场上1只「刚鬼」连接怪兽解放，以最多有那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11516241,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,11516241)
	e3:SetCost(c11516241.descost)
	e3:SetTarget(c11516241.destg)
	e3:SetOperation(c11516241.desop)
	c:RegisterEffect(e3)
end
-- 定义①效果攻击力上升的过滤条件：自己场上表侧表示且为连接怪兽。
function c11516241.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 计算这张卡攻击力上升的数值：获取自己场上除这张卡以外的连接怪兽，返回这些怪兽的连接标记合计×200。
function c11516241.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上除这张卡以外满足条件的连接怪兽的集合，用于计算攻击力上升值。
	local g=Duel.GetMatchingGroup(c11516241.atkfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	return g:GetSum(Card.GetLink)*200
end
-- 定义②效果的条件：这张卡是连接召唤出场的场合，才适用免疫效果。
function c11516241.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义②效果的免疫过滤：只免疫来自这张卡以外的卡的效果（效果所有者不是这张卡）。
function c11516241.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 定义③效果的费用选择过滤：选择自己场上1只「刚鬼」连接怪兽解放，并且要求解放后场上存在可以成为对象的卡。
function c11516241.rfilter(c,tp)
	-- 判断卡是否满足：是「刚鬼」连接怪兽，并且场上存在1张除这张卡以外可以成为效果对象的卡。
	return c:IsSetCard(0xfc) and c:IsType(TYPE_LINK) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ③效果的发动代价：选择并解放自己场上1只「刚鬼」连接怪兽，把该怪兽的连接标记数量记录到效果标签，作为可破坏对象数量上限。
function c11516241.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认时，检查自己场上是否存在1只可作为代价解放的「刚鬼」连接怪兽，且存在可成为对象的卡。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c11516241.rfilter,1,nil,tp) end
	-- 弹出选择提示，让玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择1只满足条件的「刚鬼」连接怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c11516241.rfilter,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetLink())
	-- 将选择的怪兽解放，作为效果发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ③效果的目标选择和发动处理：以解放怪兽连接标记数量为上限，选择场上1到该数量的卡为对象，设置破坏信息。
function c11516241.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 选择场上1至ct张卡为对象（ct为解放怪兽的连接标记数量）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置本次连锁的破坏信息，用于能力发动时的检测和记录。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果的解决：取得连锁对象中仍与效果关联的卡，将其破坏。
function c11516241.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象卡组，并筛选出仍与效果相关的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将筛选出的对象卡破坏（REASON_EFFECT）。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
