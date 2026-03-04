--剛鬼ザ・パワーロード・オーガ
-- 效果：
-- 战士族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡以外的自己场上的连接怪兽的连接标记合计×200。
-- ②：连接召唤的这张卡不受其他卡的效果影响。
-- ③：把自己场上1只「刚鬼」连接怪兽解放，以最多有那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
function c11516241.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个满足条件的战士族连接怪兽作为素材
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
	-- ③：把自己场上1只「刚鬼」连接怪兽解放，以最多有那个连接标记数量的场上的卡为对象才能发动。那些卡破坏。
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
-- 用于筛选场上正面表示的连接怪兽
function c11516241.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 计算攻击力上升值，通过获取场上所有正面表示的连接怪兽的连接标记总和乘以200
function c11516241.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取场上所有正面表示的连接怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(c11516241.atkfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	return g:GetSum(Card.GetLink)*200
end
-- 判断是否为连接召唤
function c11516241.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 用于过滤效果是否对自己无效
function c11516241.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 筛选满足条件的「刚鬼」连接怪兽，确保其能作为解放对象并场上有其他卡可作为目标
function c11516241.rfilter(c,tp)
	-- 筛选满足条件的「刚鬼」连接怪兽，确保其为连接怪兽且场上存在可作为目标的卡
	return c:IsSetCard(0xfc) and c:IsType(TYPE_LINK) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 设置效果发动时的解放费用，检查是否有满足条件的卡可解放
function c11516241.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件，即场上是否存在满足条件的「刚鬼」连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c11516241.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 选择满足条件的1张「刚鬼」连接怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c11516241.rfilter,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetLink())
	-- 执行解放操作，将选中的卡从场上解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标选择函数，用于选择要破坏的卡
function c11516241.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 选择最多等于解放卡连接标记数量的场上卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置效果的破坏操作函数
function c11516241.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组，并筛选出与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组中的卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
