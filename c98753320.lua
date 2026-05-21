--オルターガイスト・フェイルオーバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡以外的自己场上的卡被对方的效果破坏的场合才能发动。从手卡把1只「幻变骚灵」怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「幻变骚灵」怪兽为对象才能发动。那只怪兽加入手卡。
function c98753320.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡以外的自己场上的卡被对方的效果破坏的场合才能发动。从手卡把1只「幻变骚灵」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98753320,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,98753320)
	e2:SetCondition(c98753320.spcon)
	e2:SetTarget(c98753320.sptg)
	e2:SetOperation(c98753320.spop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地1只「幻变骚灵」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98753320,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,98753321)
	-- 把墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c98753320.thtg)
	e3:SetOperation(c98753320.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：因效果被破坏、原本在场上且原本由自己控制的卡
function c98753320.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 效果①的发动条件：由对方造成破坏，且被破坏的卡中存在满足过滤条件的卡
function c98753320.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c98753320.cfilter,1,nil,tp)
end
-- 过滤条件：手牌中可以特殊召唤的「幻变骚灵」怪兽
function c98753320.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域是否有空位、手牌中是否有可特殊召唤的「幻变骚灵」怪兽，并设置特殊召唤的操作信息）
function c98753320.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足特殊召唤条件的「幻变骚灵」怪兽
		and Duel.IsExistingMatchingCard(c98753320.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（从手牌选择1只「幻变骚灵」怪兽特殊召唤）
function c98753320.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足特殊召唤条件的「幻变骚灵」怪兽
	local g=Duel.SelectMatchingCard(tp,c98753320.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：墓地中可以加入手牌的「幻变骚灵」怪兽
function c98753320.thfilter(c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备（选择墓地中1只「幻变骚灵」怪兽作为对象，并设置加入手牌的操作信息）
function c98753320.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98753320.thfilter(chkc) end
	-- 检查自己墓地中是否存在至少1只满足条件的「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingTarget(c98753320.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地中1只满足条件的「幻变骚灵」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98753320.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理的操作信息：将选中的对象卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理（将作为对象的怪兽加入手牌）
function c98753320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与该效果相关，且不受「王家长眠之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
