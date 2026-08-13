--警衛バリケイドベルグ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡才能发动。这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的魔法卡不会被对方的效果破坏。
function c13117073.initial_effect(c)
	-- 为这张卡注册连接召唤手续：需要2只素材怪兽，且素材怪兽之间满足卡名不同的条件（由lcheck检查）。
	aux.AddLinkProcedure(c,nil,2,2,c13117073.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡连接召唤的场合，丢弃1张手卡才能发动。这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
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
	-- 设置②效果的保护对象：通过目标筛选函数，只作用于场上的魔法卡（类型为魔法卡的卡）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL))
	-- 设置②效果的适用条件：当破坏效果来源为对方时（aux.indoval），该魔法卡不会被对方的效果破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
-- 定义连接素材检查函数：比较素材组中所有怪兽的LinkCode类别数是否等于素材数量，确保素材怪兽彼此卡名不同，实现‘卡名不同的怪兽2只’。
function c13117073.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- ①效果的发动条件：判定这张卡是以连接召唤方式特殊召唤成功，满足‘这张卡连接召唤的场合’的触发条件。
function c13117073.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的发动代价：检查并执行丢弃1张手牌。若满足条件则丢弃1张手牌作为代价，对应‘丢弃1张手卡才能发动’。
function c13117073.regcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认手牌中存在至少1张可以丢弃的卡，以判断能否支付丢弃1张手牌的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌的代价：从手牌选择1张可以丢弃的卡送入墓地，丢弃原因标记为COST和DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义墓地检索目标的条件：筛选出场地魔法卡，或永续魔法卡（类型为魔法卡+永续）。
function c13117073.thfilter1(c)
	return c:IsType(TYPE_FIELD) or c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- ①效果发动后的处理：注册一个结束阶段的延迟诱发效果，在该回合结束阶段执行加入手牌的操作，并在结束阶段重置。
function c13117073.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地把1张永续魔法卡或场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c13117073.thcon)
	e1:SetOperation(c13117073.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的结束阶段诱发效果e1注册到当前玩家，使其在结束阶段可被触发并执行。
	Duel.RegisterEffect(e1,tp)
end
-- 定义墓地检索的过滤条件：必须符合thfilter1（永续魔法卡或场地魔法卡），并且该卡能够被加入手牌。
function c13117073.thfilter2(c)
	return c13117073.thfilter1(c) and c:IsAbleToHand()
end
-- 结束阶段延迟效果的发动条件：检查当前自己墓地是否存在符合条件的永续魔法卡或场地魔法卡且能加入手牌（考虑王家长眠之谷影响）。
function c13117073.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判断：检索自己墓地是否存在至少1张不受王家长眠之谷影响且满足可加入手牌的永续魔法卡或场地魔法卡。
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c13117073.thfilter2),tp,LOCATION_GRAVE,0,1,nil)
end
-- 结束阶段效果处理：提示效果与选择，从自己墓地选择1张符合条件的永续魔法卡或场地魔法卡，加入手牌并向对方展示。
function c13117073.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示卡片动画，标明正在处理“警卫 路障山巨人”的效果。
	Duel.Hint(HINT_CARD,0,13117073)
	-- 向当前玩家显示选择提示，要求其选择1张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1张符合条件的永续魔法卡或场地魔法卡（排除受王家长眠之谷影响的卡），存入g。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13117073.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌，原因是效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
