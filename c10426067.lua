--堕天使ジェフティ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
-- ②：自己场上有天使族·暗属性的融合怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「堕天使」卡或「禁忌的」速攻魔法卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片的三个效果：①通常召唤/特殊召唤时发动的特殊召唤效果；②特殊召唤时发动的特殊召唤效果；③墓地发动的手卡加入效果。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有天使族·暗属性的融合怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「堕天使」卡或「禁忌的」速攻魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	-- 将此卡除外作为cost。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤满足「堕天使」种族且不是此卡的怪兽，并且可以特殊召唤的条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足①效果的发动条件：场上存在空位且卡组存在满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动：若场上存在空位则从卡组选择1只满足条件的怪兽特殊召唤，并设置效果使本回合不能特殊召唤非天使族怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 创建并注册一个使本回合不能特殊召唤非天使族怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果目标为非天使族怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- 过滤场上存在的天使族·暗属性融合怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 判断场上是否存在天使族·暗属性融合怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在满足条件的融合怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤满足「堕天使」种族或「禁忌的」速攻魔法卡的卡。
function s.thfilter(c)
	return (c:IsSetCard(0xef)
		or c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY))
		and c:IsAbleToHand()
end
-- 设置②效果的发动条件：选择目标卡并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 判断是否满足②效果的发动条件：墓地存在满足条件的卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张满足条件的卡。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置连锁操作信息：将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理②效果的发动：将选中的卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且未受王家长眠之谷影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
