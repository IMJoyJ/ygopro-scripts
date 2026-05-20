--アルカナ ナイトジョーカー
-- 效果：
-- 「王后骑士」＋「卫兵骑士」＋「国王骑士」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：1回合1次，场上的这张卡为对象的怪兽的效果·魔法·陷阱卡发动时，把和那张卡相同种类（怪兽·魔法·陷阱）的1张手卡丢弃才能发动。那个效果无效。
function c6150044.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「王后骑士」、「卫兵骑士」、「国王骑士」，且不能使用融合代替素材
	aux.AddFusionProcCode3(c,25652259,90876561,64788463,false,false)
	-- ①：1回合1次，场上的这张卡为对象的怪兽的效果·魔法·陷阱卡发动时，把和那张卡相同种类（怪兽·魔法·陷阱）的1张手卡丢弃才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6150044,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c6150044.discon)
	e1:SetCost(c6150044.discost)
	e1:SetTarget(c6150044.distg)
	e1:SetOperation(c6150044.disop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：场上的这张卡成为效果的对象，且该效果可以被无效
function c6150044.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡片组是否包含这张卡，且该连锁的效果是否可以被无效
	return tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
-- 过滤手牌中与发动卡片相同种类且可以丢弃的卡
function c6150044.filter(c,tpe)
	return c:IsType(tpe) and c:IsDiscardable()
end
-- 定义发动代价函数：丢弃1张与发动的卡相同种类（怪兽·魔法·陷阱）的手卡
function c6150044.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=bit.band(re:GetActiveType(),0x7)
	-- 在chk==0时，检查手牌中是否存在至少1张与发动的卡相同种类的可丢弃卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6150044.filter,tp,LOCATION_HAND,0,1,nil,rtype) end
	-- 让玩家选择并丢弃1张与发动的卡相同种类的手卡作为代价
	Duel.DiscardHand(tp,c6150044.filter,1,1,REASON_COST+REASON_DISCARD,nil,rtype)
end
-- 定义发动目标函数：设置效果无效的操作信息
function c6150044.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义效果处理函数：使该连锁的效果无效
function c6150044.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
