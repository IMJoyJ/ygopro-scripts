--堕天使ジェフティ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
-- ②：自己场上有天使族·暗属性的融合怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「堕天使」卡或「禁忌的」速攻魔法卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的「堕天使」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置①效果的发动时点
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足①效果发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足①效果发动条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置①效果发动时的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 设置①效果发动后的限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- 过滤场上存在的天使族·暗属性融合怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动条件函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤满足条件的墓地卡
function s.thfilter(c)
	return (c:IsSetCard(0xef)
		or c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY))
		and c:IsAbleToHand()
end
-- 设置②效果的发动时点
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 判断是否满足②效果发动条件
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置②效果发动时的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
