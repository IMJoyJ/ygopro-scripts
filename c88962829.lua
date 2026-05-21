--騎甲虫ライト・フラッパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地的怪兽以及除外的自己怪兽之中以2只卡名不同的「骑甲虫」怪兽为对象才能发动。那些怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
-- ②：对方怪兽的攻击宣言时才能发动。这张卡回到持有者手卡，那次攻击无效。
function c88962829.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从自己墓地的怪兽以及除外的自己怪兽之中以2只卡名不同的「骑甲虫」怪兽为对象才能发动。那些怪兽加入手卡。这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88962829,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,88962829)
	e1:SetTarget(c88962829.thtg)
	e1:SetOperation(c88962829.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时才能发动。这张卡回到持有者手卡，那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88962829,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,88962830)
	e3:SetCondition(c88962829.atkcon)
	e3:SetTarget(c88962829.atktg)
	e3:SetOperation(c88962829.atkop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地或除外状态的「骑甲虫」怪兽，且该卡可以加入手牌并能成为效果对象
function c88962829.thfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x170) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsCanBeEffectTarget(e)
end
-- ①号效果的发动准备阶段，检查并选择2只卡名不同的「骑甲虫」怪兽作为效果对象
function c88962829.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c88962829.thfilter(chkc,e) end
	-- 获取自己墓地及除外区中所有符合条件的「骑甲虫」怪兽
	local g=Duel.GetMatchingGroup(c88962829.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择2张卡名不同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的怪兽注册为效果的对象
	Duel.SetTargetCard(g1)
	-- 设置连锁信息，表明该效果包含将选中的怪兽加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,#g1,0,0)
end
-- ①号效果的处理阶段，将对象怪兽加入手牌，并限制本回合该卡及同名卡的效果发动
function c88962829.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果存在有效对象，则通过效果将这些怪兽送回手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		local tg=g:Filter(c88962829.check,nil,tp)
		if #tg<=0 then return end
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,tg)
		local code_table={}
		-- 遍历成功加入手牌的卡片
		for tc in aux.Next(tg) do
			local codes={tc:GetCode()}
			for i=1,#codes do
				table.insert(code_table,codes[i])
			end
		end
		-- 这个回合，自己不能把这个效果加入手卡的卡以及那些同名卡的效果发动。②：对方怪兽的攻击宣言时才能发动。这张卡回到持有者手卡，那次攻击无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetLabel(table.unpack(code_table))
		e1:SetValue(c88962829.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境中注册该玩家本回合不能发动同名卡效果的限制
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查卡片是否成功加入手牌且由当前玩家控制
function c88962829.check(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 限制发动效果的卡片卡名与被限制的卡名相同
function c88962829.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- ②号效果的发动条件：对方怪兽进行攻击宣言时
function c88962829.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- ②号效果的发动准备，确认自身是否能回到手牌并设置操作信息
function c88962829.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁信息，表明该效果包含将自身加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②号效果的处理阶段，将自身回到手牌并使那次攻击无效
function c88962829.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡仍与效果相关，且成功回到持有者手牌
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 使对方怪兽的这次攻击无效
		Duel.NegateAttack()
	end
end
