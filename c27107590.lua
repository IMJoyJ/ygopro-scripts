--時械巫女
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
function c27107590.initial_effect(c)
	-- 效果原文：①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27107590.sprcon)
	c:RegisterEffect(e1)
	-- 效果原文：②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c27107590.dtcon)
	c:RegisterEffect(e2)
	-- 效果原文：③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27107590,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c27107590.thcost)
	e3:SetTarget(c27107590.thtg)
	e3:SetOperation(c27107590.thop)
	c:RegisterEffect(e3)
	-- 效果原文：④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27107590,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c27107590.spcost)
	e4:SetTarget(c27107590.sptg)
	e4:SetOperation(c27107590.spop)
	c:RegisterEffect(e4)
end
-- 规则层面：判断手卡中的此卡是否满足特殊召唤条件，即自己场上没有怪兽且有空位。
function c27107590.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面：判断自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 规则层面：判断自己场上是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 规则层面：判断此卡是否为「时械神」卡组。
function c27107590.dtcon(e,c)
	return c:IsSetCard(0x4a)
end
-- 规则层面：判断是否可以支付解放此卡作为发动代价。
function c27107590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面：执行将此卡解放作为发动代价的操作。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 规则层面：定义检索目标卡的过滤条件，即「时械神」怪兽且攻击力为0且可以加入手牌。
function c27107590.thfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsAbleToHand()
end
-- 规则层面：判断是否可以发动效果，即卡组中是否存在满足条件的卡。
function c27107590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断是否可以发动效果，即卡组中是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c27107590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面：设置效果处理信息，表示将从卡组检索1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行检索并加入手牌的操作，同时确认对方可见。
function c27107590.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c27107590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面：确认对方可见选中的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 规则层面：判断是否可以发动墓地效果，即本回合未特殊召唤过怪兽且此卡可以除外作为代价。
function c27107590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面：判断是否可以发动墓地效果，即本回合未特殊召唤过怪兽且此卡可以除外作为代价。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and c:IsAbleToRemoveAsCost() end
	-- 规则层面：将此卡从墓地除外作为发动代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 效果原文：④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27107590.splimit)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面：注册一个永续效果，使本回合不能特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面：定义不能特殊召唤的条件，即非本效果的其他效果不能特殊召唤。
function c27107590.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
-- 规则层面：定义特殊召唤目标卡的过滤条件，即「时械神」怪兽且攻击力为0且可以特殊召唤。
function c27107590.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 规则层面：判断是否可以发动墓地效果，即卡组中是否存在满足条件的卡且场上存在空位。
function c27107590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断卡组中是否存在满足条件的卡。
		and Duel.IsExistingMatchingCard(c27107590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置效果处理信息，表示将从卡组特殊召唤1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行特殊召唤操作。
function c27107590.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c27107590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
