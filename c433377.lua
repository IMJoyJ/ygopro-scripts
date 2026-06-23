--雷盟－ステップリーダ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己的「雷盟」卡的效果把卡破坏的场合，以自己墓地1只雷族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己主要阶段才能发动。从手卡把1只雷族怪兽特殊召唤。那之后，这张卡破坏。
-- ③：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果主函数，注册魔法卡发动效果、①效果的墓地怪兽回收效果、②效果的手牌怪兽特召并破坏自身效果，以及③效果的墓地自身回收效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「雷盟」卡的效果把卡破坏的场合，以自己墓地1只雷族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从手卡把1只雷族怪兽特殊召唤。那之后，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
-- 过滤被破坏卡片的条件：必须是因效果破坏。
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 回收效果的触发条件：自己的「雷盟」卡的效果把除此卡以外的卡片破坏的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==tp and eg:IsExists(s.dcfilter,1,c) and re:GetHandler():IsSetCard(0x1df)
end
-- 墓地雷族怪兽回收的过滤条件：是雷族怪兽，并且能够加入手牌。
function s.thfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToHand()
end
-- 回收效果的Target函数：在墓地选择1只满足条件的雷族怪兽作为效果的对象，并设置加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 效果发动时的合法性检查：检查自己墓地是否存在至少1只满足条件的雷族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1只符合条件的雷族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置回收效果操作信息：预计将所选择的目标卡片加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的Operation函数：将选为对象且不受王家长眠之谷影响的雷族怪兽加入玩家手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查所选的怪兽卡是否依然对应当前连锁，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽通过效果送入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 从手牌特殊召唤怪兽的过滤条件：是雷族怪兽，并且在当前条件下可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果的Target函数：确认主要怪兽区域有空位且手牌有可以特召的雷族怪兽，设置特殊召唤和破坏卡片的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 特召效果发动时的合法性检查：检查自己的主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己手牌中是否存在至少1只可以特殊召唤的雷族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息：预计从手牌中特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置破坏操作信息：预计将自身破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 特召效果的Operation函数：从手牌将1只雷族怪兽特殊召唤，然后破坏此卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己的主要怪兽区域是否还有可用的空位，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的雷族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果成功选择卡片且特殊召唤到场上成功。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToChain() then
		-- 中断当前效果处理，使后续的破坏自身处理与特殊召唤处理不视为同时进行。
		Duel.BreakEffect()
		-- 将这张卡通过效果破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 墓地自身回收效果的Target函数：确认此卡是否可以加入手牌，并设置加入手牌的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置回收操作信息：预计将墓地中的此卡自身加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地自身回收效果的Operation函数：将符合条件的此卡加入手牌，并向对方出示确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否依然对应当前连锁，且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡自身通过效果送入玩家手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家出示被收回手牌的这张卡以进行确认。
		Duel.ConfirmCards(1-tp,c)
	end
end
