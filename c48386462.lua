--鳴いて時鳥
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡破坏。那之后，自己抽1张。
-- ●选自己1张手卡丢弃。那之后，自己抽1张。
-- ●这个回合的结束阶段，自己抽1张。
local s,id,o=GetID()
-- 创建起动效果，设置效果描述、类型为起动效果、适用区域为主怪兽区、限制一回合一次、目标函数为s.target
function s.initial_effect(c)
	-- 效果原文内容：这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
-- 处理选择发动效果的选项并设置对应的操作和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查玩家是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 检查玩家手牌中是否存在可丢弃的卡牌且玩家可以抽卡
	local b2=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) and b1
	-- 让玩家从三个选项中选择一个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},  --"这张卡破坏。那之后，自己抽1张"
		{b2,aux.Stringid(id,2)},  --"选自己1张手卡丢弃。那之后，自己抽1张"
		{true,aux.Stringid(id,3)})  --"这个回合的结束阶段，自己抽1张"
	local cat=CATEGORY_DRAW
	if op==1 then
		cat=cat+CATEGORY_DESTROY
		e:SetOperation(s.destroy)
		-- 设置操作信息为破坏卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	elseif op==2 then
		cat=cat+CATEGORY_HANDES
		e:SetOperation(s.discard)
		-- 设置操作信息为丢弃手牌
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else e:SetOperation(s.epdelay) end
	e:SetCategory(cat)
	-- 设置操作信息为抽卡
	if op<3 then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
end
-- 处理破坏效果的执行函数，先破坏自身再抽卡
function s.destroy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否还在场上且成功破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 处理丢弃手牌效果的执行函数，先丢弃一张手牌再抽卡
function s.discard(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功丢弃手牌
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 处理回合结束阶段抽卡效果的注册函数
function s.epdelay(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个回合的结束阶段，自己抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.draw)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 处理回合结束阶段抽卡的具体执行函数
function s.draw(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 让玩家抽一张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
