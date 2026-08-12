--グングニールの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除7星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「影灵衣」怪兽为对象才能发动。那只怪兽在这个回合不会被战斗·效果破坏。
-- ②：自己·对方回合，从手卡丢弃1张「影灵衣」卡，以场上1张卡为对象才能发动。那张卡破坏。
function c74122412.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用除7星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能进行仪式召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「影灵衣」怪兽为对象才能发动。那只怪兽在这个回合不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,74122412)
	e2:SetCost(c74122412.indcost)
	e2:SetTarget(c74122412.indtg)
	e2:SetOperation(c74122412.indop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，从手卡丢弃1张「影灵衣」卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,74122413)
	e3:SetCost(c74122412.descost)
	e3:SetTarget(c74122412.destg)
	e3:SetOperation(c74122412.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：排除等级为7的怪兽，用于限制仪式召唤的素材。
function c74122412.mat_filter(c)
	return not c:IsLevel(7)
end
-- 效果①的发动代价：检查并从手牌丢弃这张卡。
function c74122412.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数：选择自己场上表侧表示的「影灵衣」怪兽。
function c74122412.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb4)
end
-- 效果①的对象选择：选择自己场上1只表侧表示的「影灵衣」怪兽作为效果对象。
function c74122412.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c74122412.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「影灵衣」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c74122412.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「影灵衣」怪兽作为效果对象。
	Duel.SelectTarget(tp,c74122412.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使目标怪兽在这个回合内不会被战斗和效果破坏。
function c74122412.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽在这个回合不会被战斗...破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数：手牌中可以丢弃的「影灵衣」卡片。
function c74122412.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsDiscardable()
end
-- 效果②的发动代价：检查并从手牌丢弃1张「影灵衣」卡。
function c74122412.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价丢弃的「影灵衣」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c74122412.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1张「影灵衣」卡作为代价丢弃送去墓地。
	Duel.DiscardHand(tp,c74122412.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的对象选择：选择场上1张卡作为效果对象，并设置破坏的操作信息。
function c74122412.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息为破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的卡片破坏。
function c74122412.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的破坏对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
