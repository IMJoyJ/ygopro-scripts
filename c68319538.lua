--宇宙砦ゴルガー
-- 效果：
-- 「外星菊石」＋调整以外的「外星」怪兽1只以上
-- ①：1回合1次，以场上的表侧表示的魔法·陷阱卡任意数量为对象才能发动。那些表侧表示的卡回到持有者手卡。那之后，回到手卡的数量的A指示物给场上的表侧表示怪兽放置。
-- ②：1回合1次，把场上2个A指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c68319538.initial_effect(c)
	-- 注册卡片记述列表：记述「外星菊石」（652362）
	aux.AddMaterialCodeList(c,652362)
	-- 添加同调召唤手续：「外星菊石」＋调整以外的「外星」怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,652362),aux.NonTuner(Card.IsSetCard,0xc),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上的表侧表示的魔法·陷阱卡任意数量为对象才能发动。那些表侧表示的卡回到持有者手卡。那之后，回到手卡的数量的A指示物给场上的表侧表示怪兽放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68319538,0))  --"魔法·陷阱卡回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c68319538.target)
	e1:SetOperation(c68319538.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把场上2个A指示物去除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68319538,1))  --"对方场上存在的1张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c68319538.descost)
	e2:SetTarget(c68319538.destg)
	e2:SetOperation(c68319538.desop)
	c:RegisterEffect(e2)
end
c68319538.counter_add_list={0x100e}
c68319538.mentioned_counter={
	[0x100e]=true,
}
-- 弹手对象过滤：场上表侧表示且可回到手牌的魔法·陷阱卡
function c68319538.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动准备与对象选择：选择场上表侧表示的魔法·陷阱卡
function c68319538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c68319538.filter(chkc) end
	-- 发动条件检查：场上是否存在表侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 发动条件检查：场上是否存在可放置A指示物的表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上任意数量（1～16张）表侧表示魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,16,nil)
	-- 设置连锁操作信息：将选中的魔陷返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①效果处理：将对象魔陷返回手牌，并给场上怪兽放置相同数量的A指示物
function c68319538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的所有对象卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将与效果关联的对象卡返回手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	local ct=rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	-- 获取场上所有可放置A指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if ct==0 or g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- ②效果Cost：去除场上2个A指示物
function c68319538.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：场上是否存在至少2个可去除的A指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 从场上去除2个A指示物
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- ②效果发动准备与对象选择：选择对方场上1张卡
function c68319538.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在可选择的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：破坏选中的对方卡片
function c68319538.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏选中的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
