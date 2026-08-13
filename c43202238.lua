--邪竜星－ガイザー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不会成为对方的效果的对象。
-- ②：以自己场上1只「龙星」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
-- ③：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只幻龙族怪兽守备表示特殊召唤。
function c43202238.initial_effect(c)
	-- 为这张卡添加同调召唤手续：要求1只调整＋1只以上调整以外的怪兽，对应「调整＋调整以外的怪兽1只以上」的素材条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置①效果的值函数，使这张卡对对方发动的效果不能成为对象（当效果发动者为对方时返回true）。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「龙星」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43202238,0))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,43202238)
	e2:SetTarget(c43202238.destg)
	e2:SetOperation(c43202238.desop)
	c:RegisterEffect(e2)
	-- ③：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把1只幻龙族怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43202238,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,43202239)
	e3:SetCondition(c43202238.spcon)
	e3:SetTarget(c43202238.sptg)
	e3:SetOperation(c43202238.spop)
	c:RegisterEffect(e3)
end
-- 定义②效果中选择「龙星」怪兽的过滤条件：表侧表示且属于「龙星」系列（0x9e）。
function c43202238.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e)
end
-- ②效果发动时的目标选择条件：自己场上存在1只表侧表示的「龙星」怪兽，且对方场上存在1张卡可以作为对象。
function c43202238.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时（chk==0）检查自己场上是否存在1只满足desfilter的表侧「龙星」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c43202238.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在1张可以被选择为对象的卡（用aux.TRUE表示无条件存在卡）。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 在选择卡片前向玩家显示“请选择要破坏的卡”的提示信息，用于卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只表侧表示的「龙星」怪兽，并将其设为效果对象。
	local g1=Duel.SelectTarget(tp,c43202238.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 在第二次选择前再次显示“请选择要破坏的卡”的提示信息，用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡，并将其设为效果对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 将本次连锁的破坏效果信息登记为破坏2张卡（对象卡组为g1），供后续处理及相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果处理时，获取连锁对象中仍与效果相关的卡，并以效果原因将其破坏。
function c43202238.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡组，即自己场上的「龙星」怪兽和对方场上被选中的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以效果原因破坏筛选出的对象卡。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ③效果的发动条件：这张卡因战斗或效果被破坏并送去墓地，且破坏前在自己场上。
function c43202238.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义从卡组特殊召唤的卡的过滤条件：幻龙族怪兽，且可以表侧守备表示特殊召唤。
function c43202238.spfilter(c,e,tp)
	return c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果发动时检查自己场上是否有空位，且卡组中存在符合条件的幻龙族怪兽。
function c43202238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查自己的主要怪兽区是否有空位，以准备特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在1只满足spfilter（幻龙族且可表侧守备特召）的怪兽。
		and Duel.IsExistingMatchingCard(c43202238.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的特殊召唤效果信息登记为从卡组特殊召唤1只怪兽，供后续处理及相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理时，若场上仍有空位，则从卡组选择1只幻龙族怪兽，以表侧守备表示特殊召唤。
function c43202238.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区有空位，若没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 在从卡组选择特殊召唤的怪兽前显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足spfilter的幻龙族怪兽，作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c43202238.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
