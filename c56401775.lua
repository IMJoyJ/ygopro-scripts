--メルフィー・ポニィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到持有者手卡。那之后，可以从自己墓地选「童话动物·小马」以外的1只2星以下的兽族怪兽加入手卡。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c56401775.initial_effect(c)
	-- ①：对方对怪兽的召唤·特殊召唤成功的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到持有者手卡。那之后，可以从自己墓地选「童话动物·小马」以外的1只2星以下的兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56401775,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56401775)
	e1:SetCondition(c56401775.thcon)
	e1:SetTarget(c56401775.thtg)
	e1:SetOperation(c56401775.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c56401775.thcon2)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56401775,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,56401776)
	e4:SetCondition(c56401775.spcon)
	e4:SetTarget(c56401775.sptg)
	e4:SetOperation(c56401775.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：检查怪兽的召唤·特殊召唤控制者是否为指定玩家
function c56401775.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 效果①发动条件：对方对怪兽的召唤·特殊召唤成功
function c56401775.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56401775.cfilter,1,nil,1-tp)
end
-- 效果①发动条件：这张卡被选择作为对方怪兽的攻击对象
function c56401775.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果①的发动准备：检查自身是否能回到手卡，并设置操作信息
function c56401775.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置当前连锁的操作信息为：将自身送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤条件：自己墓地「童话动物·小马」以外的2星以下的兽族怪兽
function c56401775.thfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(2) and not c:IsCode(56401775) and c:IsAbleToHand()
end
-- 效果①的效果处理：将自身送回手卡，之后可选择将墓地符合条件的兽族怪兽加入手卡
function c56401775.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍适用效果，并成功将自身送回手卡且确实存在于手卡中
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查自己墓地是否存在满足条件的兽族怪兽（受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c56401775.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否选择发动后续的回收墓地怪兽效果
		and Duel.SelectYesNo(tp,aux.Stringid(56401775,2)) then  --"是否从墓地把卡加入手卡？"
		-- 中断当前效果处理，使之后的效果（回收墓地怪兽）与之前的效果（自身回手卡）视为不同时处理（那之后）
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己墓地选择1张满足条件的兽族怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56401775.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 效果②发动条件：当前回合是自己的回合
function c56401775.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的发动准备：检查怪兽区域是否有空位、自身是否能特殊召唤，并设置特殊召唤的操作信息
function c56401775.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格，且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤
function c56401775.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
