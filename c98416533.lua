--メルフィー・ワラビィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小小袋鼠」以外的2只「童话动物」怪兽特殊召唤（同名卡最多1张）。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c98416533.initial_effect(c)
	-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小小袋鼠」以外的2只「童话动物」怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98416533,0))  --"这张卡回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,98416533)
	e1:SetCondition(c98416533.thcon)
	e1:SetTarget(c98416533.thtg)
	e1:SetOperation(c98416533.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c98416533.thcon2)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(98416533,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,98416534)
	e4:SetCondition(c98416533.spcon)
	e4:SetTarget(c98416533.sptg)
	e4:SetOperation(c98416533.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽的召唤/特殊召唤玩家是否为指定玩家
function c98416533.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 发动条件：对方成功召唤·特殊召唤怪兽的场合
function c98416533.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98416533.cfilter,1,nil,1-tp)
end
-- 发动条件：这张卡被选择作为对方怪兽的攻击对象时
function c98416533.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断进行攻击的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果1的发动准备：检查自身是否能回到手卡，并设置回到手卡的操作信息
function c98416533.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将自身送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 过滤条件：卡组中「童话动物·小小袋鼠」以外的、可以特殊召唤的「童话动物」怪兽
function c98416533.spfilter(c,e,tp)
	return c:IsSetCard(0x146) and not c:IsCode(98416533) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的效果处理：将自身送回手卡，之后可选择从卡组特殊召唤2只卡名不同的「童话动物」怪兽
function c98416533.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足特殊召唤条件的「童话动物·小小袋鼠」以外的「童话动物」怪兽
	local g=Duel.GetMatchingGroup(c98416533.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若此卡仍存在于场上，则将其送回手卡，并确认其已成功到达手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:GetClassCount(Card.GetCode)>1
		-- 询问玩家是否选择从卡组特殊召唤怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(98416533,2)) then  --"是否从卡组特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与回手卡不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从符合条件的卡片中选择2张卡名不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的2只怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果2的发动条件：当前回合是自己的回合
function c98416533.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果2的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c98416533.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时，检查自己场上是否有空余的怪兽区域，且手卡中的这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果2的效果处理：将手卡中的这张卡特殊召唤
function c98416533.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
