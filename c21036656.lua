--円喚妖精キクロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把「圆唤妖精 蘑菇圈」以外的1只昆虫族·植物族的调整加入手卡。
-- ②：这张卡在墓地存在的状态，昆虫族·植物族同调怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片的三个效果：①通常召唤成功时的检索效果、②特殊召唤成功时的检索效果、③墓地时的特殊召唤效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把「圆唤妖精 蘑菇圈」以外的1只昆虫族·植物族的调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，昆虫族·植物族同调怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	-- 为卡片注册一个送入墓地事件监听效果，用于记录卡片是否已进入墓地状态
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动费用：丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动费用条件：手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行效果①的发动费用：丢弃1张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数：排除自身，筛选昆虫族·植物族调整
function s.filter(c)
	return not c:IsCode(id) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsAbleToHand()
end
-- 效果①的发动宣言：检索满足条件的1张卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动宣言条件：卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的处理信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地发动效果的过滤函数：筛选昆虫族·植物族同调怪兽
function s.cfilter(c,tp,se)
	return c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsType(TYPE_SYNCHRO)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件：场上存在昆虫族·植物族同调怪兽被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 效果②的发动宣言：特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的发动宣言条件：场上存在可特殊召唤的位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果②的处理信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：特殊召唤此卡并设置离开场上的除外效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足效果②的处理条件：此卡在场上且可特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤后设置此卡离开场上的除外效果：从场上离开时移至除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
