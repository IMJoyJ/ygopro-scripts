--メギストリーの儀術師
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：自己·对方的结束阶段把这张卡3个魔力指示物取除，以除外的1张自己的魔法卡为对象才能发动。把1张那张卡的同名卡从卡组加入手卡。
function c83035296.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 注册连锁发生检测：用于追踪魔法卡发动的连锁流程
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 注册连锁标记回调函数（辅助判定连锁发动）
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c83035296.acop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段把这张卡3个魔力指示物去除，以除外的1张自己的魔法卡为对象才能发动。把1张那张卡的同名卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83035296,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,83035296)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCost(c83035296.thcost)
	e2:SetTarget(c83035296.thtg)
	e2:SetOperation(c83035296.thop)
	c:RegisterEffect(e2)
end
c83035296.mentioned_counter={
	[0x1]=true,
}
-- 指示物放置处理：魔法卡发动成功且在此卡场上存在时，放置1个魔力指示物
function c83035296.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果发动Cost：去除此卡上3个魔力指示物
function c83035296.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 除外区对象过滤：表侧表示的魔法卡，且卡组中存在同名卡
function c83035296.thfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
		-- 检查卡组中是否存在该魔法卡的同名卡
		and Duel.IsExistingMatchingCard(c83035296.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 卡组检索过滤：同名且可加入手牌
function c83035296.thfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- ②效果发动准备：选择除外区1张魔法卡为对象，并设置从卡组检索同名卡的操作信息
function c83035296.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c83035296.thfilter1(chkc,tp) end
	-- 发动条件检查：除外区存在符合条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c83035296.thfilter1,tp,LOCATION_REMOVED,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择除外区1张魔法卡作为连锁对象
	Duel.SelectTarget(tp,c83035296.thfilter1,tp,LOCATION_REMOVED,0,1,1,nil,tp)
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组把1张作为对象的魔法卡的同名卡加入手牌
function c83035296.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张与对象卡同名的卡
		local g=Duel.SelectMatchingCard(tp,c83035296.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的同名卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
