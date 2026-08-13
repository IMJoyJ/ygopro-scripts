--宇宙砦ゴルガー
-- 效果：
-- 「外星菊石」＋调整以外的「外星」怪兽1只以上
-- ①：1回合1次，以场上的表侧表示的魔法·陷阱卡任意数量为对象才能发动。那些表侧表示的卡回到持有者手卡。那之后，回到手卡的数量的A指示物给场上的表侧表示怪兽放置。
-- ②：1回合1次，把场上2个A指示物取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c68319538.initial_effect(c)
	-- 为这张卡声明同调素材卡名列表：指定「外星菊石」（卡号652362）为其特定同调素材
	aux.AddMaterialCodeList(c,652362)
	-- 为这张卡添加同调召唤手续：以1只「外星菊石」作为调整，加上至少1只调整以外的「外星」怪兽作为同调素材
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
c68319538.mentioned_counter={
	[0x100e]=true,
}
-- 定义过滤函数：场上表侧表示的魔法·陷阱卡且可以回到手卡的卡
function c68319538.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的对象处理入口：连锁对象合法性检查，并确认场上存在可选择的表侧表示魔法·陷阱卡且存在可以放置A指示物的怪兽
function c68319538.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c68319538.filter(chkc) end
	-- 检查场上是否存在至少1张可成为效果对象的表侧表示魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 并检查场上是否存在至少1只可以放置A指示物的表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x100e,1) end
	-- 向玩家发出选择提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 以场上1~16张表侧表示的魔法·陷阱卡为对象，将其选为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,c68319538.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,16,nil)
	-- 设置操作信息：将这些对象的卡作为回手牌处理，数量为所选卡的数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的处理：将对象的表侧表示魔法·陷阱卡回到持有者手卡，然后按回到手卡的数量，每次选择场上1只表侧表示怪兽放置1个A指示物
function c68319538.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将与效果仍有关联的对象卡以效果原因送去持有者手卡
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	local ct=rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	-- 检索场上全部可以放置A指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x100e,1)
	if ct==0 or g:GetCount()==0 then return end
	for i=1,ct do
		-- 向玩家发出选择提示「请选择要放置指示物的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
-- 效果②的代价：作为发动代价取除场上2个A指示物
function c68319538.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能以代价原因取除场上2个A指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 以代价原因取除场上2个A指示物
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 效果②的对象处理：确认对方场上存在1张可成为对象的卡，选择对方场上1张卡为对象并设置破坏的操作信息
function c68319538.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发出选择提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以对方场上1张卡为对象，将其选为当前连锁的效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将对象的卡作为破坏处理，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理：取得对象卡，若其仍与此效果关联，则将其以效果原因破坏
function c68319538.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏那张对方的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
