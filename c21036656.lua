--円喚妖精キクロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，丢弃1张手卡才能发动。从卡组把「圆唤妖精 蘑菇圈」以外的1只昆虫族·植物族的调整加入手卡。
-- ②：这张卡在墓地存在的状态，昆虫族·植物族同调怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册这张卡的全部效果：①的召唤/特殊召唤检索效果（e1/e2）和②的墓地特殊召唤效果（e3），并为②效果的墓地状态检测注册标记。
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
	-- 为这张卡注册“已在墓地”状态标记，防止在同一连锁中因刚被送去墓地而错误判定为墓地存在，保证②效果的发动条件准确。
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
-- 定义①效果的发动代价：丢弃1张手卡。先检查能否支付，再实际丢弃1张手卡作为代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认手牌中存在至少1张可以丢弃的手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择1张可丢弃的手卡丢弃，丢弃原因记为代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索筛选条件：不是同名卡「圆唤妖精 蘑菇圈」，是昆虫族或植物族，是调整怪兽，并且可以被加入手卡。
function s.filter(c)
	return not c:IsCode(id) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsAbleToHand()
end
-- ①效果的目标检查：确认卡组中存在至少1张符合检索条件的昆虫族·植物族调整，并设置本次操作将把卡组中的卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足s.filter条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将从卡组把1张卡加入手卡（不取对象，数量1，目标为自己卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1张符合条件的昆虫族·植物族调整加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示信息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组筛选并选择1张符合条件的卡片（效果处理时不取对象）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果触发条件过滤：特殊召唤的怪兽是昆虫族或植物族同调怪兽，且该特殊召唤不是本次②效果自身造成的。
function s.cfilter(c,tp,se)
	return c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsType(TYPE_SYNCHRO)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：本次特殊召唤的怪兽中存在满足s.cfilter条件的昆虫族·植物族同调怪兽（排除本卡效果自身引发的特殊召唤）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- ②效果的目标检查：主要怪兽区有空位，且墓地中的这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区格子用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将特殊召唤墓地中的这张卡（对象为自己，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地中的这张卡以表侧表示特殊召唤，若成功则给它附加“从场上离开时除外”的持续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡仍与效果关联，并尝试将其表侧表示特殊召唤；若特殊召唤成功（返回值大于0），则继续设置离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
