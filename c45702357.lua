--リバーシブル・ビートル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。这张卡以及和这张卡相同纵列的怪兽全部变成里侧守备表示。
-- ②：这张卡反转的场合发动。这张卡以及和这张卡相同纵列的表侧表示怪兽全部回到持有者卡组。
function c45702357.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。这张卡以及和这张卡相同纵列的怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45702357,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,45702357)
	e1:SetTarget(c45702357.postg)
	e1:SetOperation(c45702357.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡反转的场合发动。这张卡以及和这张卡相同纵列的表侧表示怪兽全部回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45702357,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e3:SetCountLimit(1,45702358)
	e3:SetTarget(c45702357.tdtg)
	e3:SetOperation(c45702357.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否在相同纵列且可以转为里侧表示
function c45702357.posfilter(c,g)
	return g:IsContains(c) and c:IsCanTurnSet()
end
-- 设置连锁处理信息，确定将要改变表示形式的怪兽组
function c45702357.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	-- 获取满足条件的怪兽组，即在相同纵列且可以转为里侧表示的怪兽
	local g=Duel.GetMatchingGroup(c45702357.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置连锁操作信息，指定将要改变表示形式的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行将怪兽变为里侧守备表示的操作
function c45702357.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	if c:IsRelateToEffect(e) then
		-- 获取满足条件的怪兽组，即在相同纵列且可以转为里侧表示的怪兽
		local g=Duel.GetMatchingGroup(c45702357.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
		if g:GetCount()>0 then
			-- 将指定怪兽全部变为里侧守备表示
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤函数，用于判断目标怪兽是否在相同纵列且可以送回卡组
function c45702357.tdfilter(c,g)
	return c:IsFaceup() and g:IsContains(c) and c:IsAbleToDeck()
end
-- 设置连锁处理信息，确定将要送回卡组的怪兽组
function c45702357.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) then cg:AddCard(c) end
	-- 获取满足条件的怪兽组，即在相同纵列且可以送回卡组的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c45702357.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置连锁操作信息，指定将要送回卡组的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理函数，执行将怪兽送回卡组的操作
function c45702357.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) then cg:AddCard(c) end
	if c:IsRelateToEffect(e) then
		-- 获取满足条件的怪兽组，即在相同纵列且可以送回卡组的表侧表示怪兽
		local g=Duel.GetMatchingGroup(c45702357.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
		if g:GetCount()>0 then
			-- 将指定怪兽全部送回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
