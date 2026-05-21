--昇竜剣士マジェスターP
-- 效果：
-- 4星灵摆怪兽×2
-- ①：这张卡超量召唤成功时才能发动。这个回合的结束阶段，从卡组把1只灵摆怪兽加入手卡。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从自己的额外卡组把1只表侧表示的「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为超量召唤的素材。
function c88722973.initial_effect(c)
	-- 设置XYZ召唤手续：4星灵摆怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_PENDULUM),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时才能发动。这个回合的结束阶段，从卡组把1只灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88722973,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88722973.regcon)
	e1:SetOperation(c88722973.regop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。从自己的额外卡组把1只表侧表示的「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为超量召唤的素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88722973,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c88722973.spcost)
	e2:SetTarget(c88722973.sptg)
	e2:SetOperation(c88722973.spop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否通过超量召唤特殊召唤成功
function c88722973.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 在超量召唤成功时，注册一个在回合结束阶段触发的延迟效果
function c88722973.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡超量召唤成功时才能发动。这个回合的结束阶段，从卡组把1只灵摆怪兽加入手卡。②：1回合1次，把这张卡1个超量素材取除才能发动。从自己的额外卡组把1只表侧表示的「龙剑士」灵摆怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c88722973.thcon)
	e1:SetOperation(c88722973.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段检索的效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤卡组中可以加入手牌的灵摆怪兽
function c88722973.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检查卡组中是否存在可以加入手牌的灵摆怪兽
function c88722973.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组中是否存在至少1张可以加入手牌的灵摆怪兽
	return Duel.IsExistingMatchingCard(c88722973.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段检索效果的具体处理：从卡组选择1只灵摆怪兽加入手牌
function c88722973.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在决斗界面展示卡片“升龙剑士 威风星·圣骑”的发动提示
	Duel.Hint(HINT_CARD,0,88722973)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c88722973.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的起动费用：取除这张卡的1个超量素材
function c88722973.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤额外卡组中表侧表示、可以特殊召唤的「龙剑士」灵摆怪兽，并检查额外怪兽区域或连接端是否有可用位置
function c88722973.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xc7) and c:IsType(TYPE_PENDULUM)
		-- 检查该卡是否可以特殊召唤，且额外卡组怪兽出场的可用区域空格数大于0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的目标检查与操作信息设置
function c88722973.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足特殊召唤条件的表侧表示「龙剑士」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88722973.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从额外卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的具体处理：从额外卡组特殊召唤1只表侧表示的「龙剑士」灵摆怪兽，并施加不能作为超量召唤素材的限制
function c88722973.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的表侧表示「龙剑士」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c88722973.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽不能作为超量召唤的素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
