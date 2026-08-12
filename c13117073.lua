--警衛バリケイドベルグ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡才能发动。这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法卡不会被对方的效果破坏。
function c13117073.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只怪兽作为连接素材，且卡名不能相同
	aux.AddLinkProcedure(c,nil,2,2,c13117073.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，丢弃1张手卡才能发动。这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13117073,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,13117073)
	e1:SetCondition(c13117073.regcon)
	e1:SetCost(c13117073.regcost)
	e1:SetOperation(c13117073.regop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	-- 效果目标为场上所有表侧表示的魔法卡
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL))
	-- 效果值为过滤函数，判断是否为对方的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
-- 连接召唤时用于检查连接素材的卡名是否不重复
function c13117073.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果发动条件：这张卡是连接召唤成功
function c13117073.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动代价：丢弃1张手卡
function c13117073.regcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数：判断是否为场地魔法或永续魔法
function c13117073.thfilter1(c)
	return c:IsType(TYPE_FIELD) or c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 效果发动操作：在结束阶段从墓地将1张符合条件的魔法卡加入手卡
function c13117073.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡连接召唤的场合，丢弃1张手卡才能发动。这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c13117073.thcon)
	e1:SetOperation(c13117073.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 检索过滤函数：判断是否为场地魔法或永续魔法且能加入手卡
function c13117073.thfilter2(c)
	return c13117073.thfilter1(c) and c:IsAbleToHand()
end
-- 检索条件函数：判断墓地是否存在满足条件的魔法卡
function c13117073.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断墓地是否存在满足条件的魔法卡
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c13117073.thfilter2),tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果发动操作：选择并把符合条件的魔法卡加入手卡
function c13117073.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动卡片的动画
	Duel.Hint(HINT_CARD,0,13117073)
	-- 提示选择卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13117073.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡送入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
