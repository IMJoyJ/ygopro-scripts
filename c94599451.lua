--魔導研究所
-- 效果：
-- ①：每次自己场上的表侧表示的「魔导兽」灵摆怪兽卡被战斗·效果破坏给这张卡放置2个魔力指示物。
-- ②：1回合1次，把自己场上的魔力指示物任意数量取除才能发动。从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选持有和取除数量相同等级的1只可以放置魔力指示物的怪兽加入手卡。
-- ③：场上的这张卡被效果破坏的场合，可以作为代替把这张卡1个魔力指示物取除。
function c94599451.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次自己场上的表侧表示的「魔导兽」灵摆怪兽卡被战斗·效果破坏给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c94599451.ctcon)
	e2:SetOperation(c94599451.ctop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己场上的魔力指示物任意数量取除才能发动。从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选持有和取除数量相同等级的1只可以放置魔力指示物的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94599451,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c94599451.thtg)
	e3:SetOperation(c94599451.thop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被效果破坏的场合，可以作为代替把这张卡1个魔力指示物取除。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c94599451.reptg)
	e4:SetOperation(c94599451.repop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上因战斗或效果被破坏的表侧表示的「魔导兽」灵摆怪兽卡
function c94599451.ctfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsType(TYPE_PENDULUM) and c:IsPreviousSetCard(0x10d) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检查被破坏的卡中是否存在满足条件的自己场上的表侧表示「魔导兽」灵摆怪兽
function c94599451.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94599451.ctfilter,1,nil,tp)
end
-- 给这张卡放置2个魔力指示物
function c94599451.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,2)
end
-- 过滤卡组中的怪兽或额外卡组表侧表示的灵摆怪兽中，等级大于0、可以放置魔力指示物、且能通过去除对应数量的魔力指示物来检索的卡
function c94599451.thfilter1(c,tp)
	local lv=c:GetLevel()
	return (c:IsLocation(LOCATION_DECK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) and lv>0 and c:IsCanHaveCounter(0x1)
		-- 检查是否能从自己场上移除与该怪兽等级相同数量的魔力指示物作为发动成本，且该怪兽能加入手卡
		and Duel.IsCanRemoveCounter(tp,1,0,0x1,lv,REASON_COST) and c:IsAbleToHand()
end
-- 检索效果的发动准备与目标选择，计算可选择的等级并让玩家宣言要去除的指示物数量，支付成本并设置操作信息
function c94599451.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1张满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94599451.thfilter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	-- 获取卡组及额外卡组中所有满足检索条件的怪兽卡组
	local g=Duel.GetMatchingGroup(c94599451.thfilter1,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要取除的魔力指示物数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(94599451,1))  --"请选择要取除的指示物的数量"
	-- 让玩家宣言一个可选择的等级（即要取除的指示物数量）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 从自己场上取除与宣言等级相同数量的魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,lv,REASON_COST)
	e:SetLabel(lv)
	-- 设置连锁的操作信息为“从卡组或额外卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤卡组或额外卡组表侧表示的、可以放置魔力指示物且等级与取除数量相同的怪兽
function c94599451.thfilter2(c,lv)
	return (c:IsLocation(LOCATION_DECK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) and c:IsCanHaveCounter(0x1)
		and c:IsLevel(lv) and c:IsAbleToHand()
end
-- 检索效果的处理，让玩家选择1只等级与取除数量相同的怪兽加入手卡
function c94599451.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或额外卡组中选择1张等级与取除数量相同的怪兽
	local g=Duel.SelectMatchingCard(tp,c94599451.thfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,lv)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏效果的目标检查，确认自身因效果被破坏且有足够的魔力指示物可取除，并询问玩家是否使用代替效果
function c94599451.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT) and c:IsCanRemoveCounter(tp,0x1,1,REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否适用代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的具体处理，取除这张卡上的1个魔力指示物
function c94599451.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_EFFECT)
end
