--空牙団の剣士 ビート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的剑士 比特」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合才能发动。从卡组把「空牙团的剑士 比特」以外的1只「空牙团」怪兽加入手卡。
function c93850652.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的剑士 比特」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93850652,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,93850652)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c93850652.sptg)
	e1:SetOperation(c93850652.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合才能发动。从卡组把「空牙团的剑士 比特」以外的1只「空牙团」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93850652,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,93850653)
	e2:SetCondition(c93850652.thcon)
	e2:SetTarget(c93850652.thtg)
	e2:SetOperation(c93850652.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除「空牙团的剑士 比特」以外的「空牙团」怪兽，且能被特殊召唤
function c93850652.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(93850652) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查（检查怪兽区域是否有空位，以及手卡中是否存在可特殊召唤的符合条件的怪兽）
function c93850652.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c93850652.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（从手卡选择1只符合条件的「空牙团」怪兽特殊召唤）
function c93850652.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c93850652.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的「空牙团」怪兽
function c93850652.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 效果②的发动条件：自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合
function c93850652.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c93850652.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中除「空牙团的剑士 比特」以外的1只「空牙团」怪兽，且能加入手卡
function c93850652.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_MONSTER) and not c:IsCode(93850652) and c:IsAbleToHand()
end
-- 效果②的发动准备与合法性检查（检查卡组中是否存在可检索的符合条件的怪兽）
function c93850652.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足检索过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93850652.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组将1只符合条件的「空牙团」怪兽加入手卡）
function c93850652.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c93850652.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
