--風帝家臣ガルーム
-- 效果：
-- 「风帝家臣 迦楼姆」的①②的效果1回合各能使用1次。
-- ①：让自己场上1只上级召唤的怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。从卡组把「风帝家臣 迦楼姆」以外的1只攻击力800/守备力1000的怪兽加入手卡。
function c22382087.initial_effect(c)
	-- 「①：让自己场上1只上级召唤的怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22382087)
	e1:SetCost(c22382087.spcost)
	e1:SetTarget(c22382087.sptg)
	e1:SetOperation(c22382087.spop)
	c:RegisterEffect(e1)
	-- 「②：这张卡为上级召唤而被解放的场合才能发动。从卡组把「风帝家臣 迦楼姆」以外的1只攻击力800/守备力1000的怪兽加入手卡。」
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,22382088)
	e2:SetCondition(c22382087.thcon)
	e2:SetTarget(c22382087.thtg)
	e2:SetOperation(c22382087.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果代价的筛选条件：我方场上1只进行过上级召唤的怪兽，且该怪兽能够作为代价返回手卡。
function c22382087.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- ①效果的代价处理：检查时确认我方场上是否存在符合条件的上级召唤怪兽；实际发动时选择1只返回持有者手卡作为代价。
function c22382087.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1只满足“上级召唤过”且能被返回手卡的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c22382087.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 由发动玩家从自己场上选择1只满足筛选条件的上级召唤怪兽，作为效果发动的代价。
	local g=Duel.SelectMatchingCard(tp,c22382087.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将所选怪兽返回其持有者手卡，支付原因标记为REASON_COST，作为发动效果的代价。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- ①效果的目标条件判定：确认自己主要怪兽区有可供特殊召唤的空格（用-1容忍代价先腾出格子），并且这张卡自身满足特殊召唤条件，满足才能发动。
function c22382087.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格；由于代价处理前判断，用-1表示允许通过返回怪兽腾出1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：本效果将特殊召唤这张卡，供其他需要检测操作信息的卡（如星尘龙）参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：先给发动玩家施加直到结束阶段不能从额外卡组特殊召唤怪兽的自肃效果；然后若这张卡仍与效果关联，则将其表侧表示特殊召唤。
function c22382087.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 「这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。②：这张卡为上级召唤而被解放的场合才能发动。从卡组把「风帝家臣 迦楼姆」以外的1只攻击力800/守备力1000的怪兽加入手卡。」
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22382087.splimit)
	-- 将刚创建的自肃效果注册到当前玩家tp身上，使该玩家受到“不能从额外卡组特殊召唤”的限制。
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示形式特殊召唤到发动玩家的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 自肃效果的判定函数：若试图特殊召唤的怪兽来自额外卡组，则禁止该特殊召唤。
function c22382087.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：这张卡被解放时，判断其解放原因是否为上级召唤（REASON_SUMMON），以确认是“为上级召唤而被解放的场合”。
function c22382087.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 定义检索条件：从卡组中筛选攻击力800、守备力1000、卡名不是「风帝家臣 迦楼姆」且可以被加入手卡的怪兽。
function c22382087.filter(c)
	return c:IsAttack(800) and c:IsDefense(1000) and not c:IsCode(22382087) and c:IsAbleToHand()
end
-- ②效果的目标检查与操作信息登记：确认卡组中存在至少1只满足检索条件的怪兽，并登记本次操作是将1张卡从卡组加入手卡。
function c22382087.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：卡组中是否存在满足检索条件的怪兽，若不存在则②效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c22382087.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁将进行的操作：从卡组把1只符合条件的怪兽加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的怪兽加入手卡，并向对方展示确认。
function c22382087.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1只满足检索条件的怪兽，作为要加入手卡的目标。
	local g=Duel.SelectMatchingCard(tp,c22382087.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的检索目标加入其持有者的手卡，原因标记为REASON_EFFECT（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
