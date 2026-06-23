--剛鬼ジャドウ・オーガ
-- 效果：
-- 「刚鬼」怪兽2只
-- ①：1回合1次，这张卡所连接区的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以从自己墓地选「刚鬼 邪道食人魔」以外的1只「刚鬼」怪兽特殊召唤。
function c10552026.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只以上满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2,2)
	-- ①：1回合1次，这张卡所连接区的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以从自己墓地选「刚鬼 邪道食人魔」以外的1只「刚鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10552026,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c10552026.negcon)
	e1:SetTarget(c10552026.negtg)
	e1:SetOperation(c10552026.negop)
	c:RegisterEffect(e1)
end
-- 判断效果发动时是否满足条件
function c10552026.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取当前连锁的发动位置、序号和控制者
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then seq=seq+16 end
	-- 判断发动效果是否为怪兽类型、是否在主要怪兽区、是否在连接区、是否可以被无效
	return re:IsActiveType(TYPE_MONSTER) and bit.band(loc,LOCATION_MZONE)~=0 and bit.extract(c:GetLinkedZone(),seq)~=0 and Duel.IsChainNegatable(ev)
end
-- 设置连锁发动时的效果处理目标
function c10552026.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的效果分类
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的效果分类
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义特殊召唤的过滤条件
function c10552026.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and not c:IsCode(10552026) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果处理操作
function c10552026.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并破坏对象卡片
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 检查是否有足够的特殊召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 检索满足条件的墓地怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10552026.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有满足条件的怪兽且玩家选择特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(10552026,1)) then  --"是否选「刚鬼」怪兽特殊召唤？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			-- 将符合条件的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
