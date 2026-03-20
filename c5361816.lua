--聖騎士ペリノア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡装备的1张「圣剑」装备魔法卡和对方场上1只表侧表示怪兽为对象才能发动。那些卡破坏。那之后，自己从卡组抽1张。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c5361816.initial_effect(c)
	-- 创建效果1，用于处理圣骑士佩里诺尔的起动效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5361816,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c5361816.destg)
	e1:SetOperation(c5361816.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选装备在圣骑士佩里诺尔上的「圣剑」装备魔法卡
function c5361816.desfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0x207a) and g:IsContains(c)
end
-- 效果的发动条件判断函数，检查是否满足发动条件
function c5361816.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetEquipGroup()
	if chkc then return false end
	-- 检查玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查玩家场上是否存在满足条件的「圣剑」装备魔法卡
		and Duel.IsExistingTarget(c5361816.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,g)
		-- 检查对方场上是否存在至少一只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的「圣剑」装备魔法卡作为对象
	local g1=Duel.SelectTarget(tp,c5361816.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,g)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只表侧表示的怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时要破坏的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 设置效果处理时要抽卡的信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的处理函数，执行破坏和抽卡操作
function c5361816.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断被选择的卡是否有效并执行破坏
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 中断当前效果，使后续效果不同时处理
		Duel.BreakEffect()
		-- 让玩家从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使这张卡在本回合不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
