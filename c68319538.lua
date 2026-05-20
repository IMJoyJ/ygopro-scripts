--宇宙砦ゴルガー
-- 效果：
-- 「外星菊石」＋调整以外的「外星」怪兽1只以上
-- ①：1回合1次，以场上的表侧表示的魔法·陷阱卡任意数量为对象才能发动。那些表侧表示的卡回到持有者手卡。那之后，回到手卡的数量的A指示物给场上的表侧表示怪兽放置。
-- ②：1回合1次，把场上2个A指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c68319538.initial_effect(c)
	-- 将「外星菊石」加入此卡的素材代码列表中
	aux.AddMaterialCodeList(c,652362)
	-- 添加同调召唤手续：以「外星菊石」为调整，调整以外的「外星」怪兽1只以上
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
	-- ②：1回合1次，把场上2个A指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
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
-- 过滤场上表侧表示且可以回到手牌的魔法·陷阱卡
function c68319538.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测函数
function c68319538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c68319538.filter(chkc) end
	-- 检测场上是否存在至少1张可以回到手牌的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 并且检测场上是否存在至少1只可以放置A指示物的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上任意数量（最多16张）表侧表示的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,16,nil)
	-- 设置效果处理信息为：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的效果处理函数（将卡片送回手牌，并放置对应数量的A指示物）
function c68319538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍存在于场上的对象卡片送回持有者手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	local ct=rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	-- 获取场上所有可以放置A指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if ct==0 or g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- 效果②的发动代价检测与执行函数
function c68319538.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否可以取除2个A指示物作为发动代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 从场上取除2个A指示物作为发动代价
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 效果②的发动准备与合法性检测函数
function c68319538.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检测对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理函数（破坏选中的卡）
function c68319538.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
