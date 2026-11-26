--メルフィー・ワラビィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小小袋鼠」以外的2只「童话动物」怪兽特殊召唤（同名卡最多1张）。
-- ②：自己结束阶段才能发动。这张卡从手卡特殊召唤。
function c98416533.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到手卡。那之后，可以从卡组把「童话动物·小小袋鼠」以外的2只「童话动物」怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98416533,0))  --"这张卡回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 筛选条件：检查怪兽是否为指定玩家召唤·特殊召唤的怪兽
function c98416533.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- ①效果（对方召唤·特召分支）的发动条件检查：确认本次召唤或特殊召唤的怪兽中存在对方召唤·特殊召唤的怪兽
function c98416533.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98416533.cfilter,1,nil,1-tp)
end
-- ①效果（被攻击分支）的发动条件检查：确认本次攻击的攻击怪兽由对方控制
function c98416533.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击宣言的攻击怪兽控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果的发动检测与连锁信息设置：确认这张卡可以回到手卡并登记返回手卡操作信息
function c98416533.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 登记连锁的返回手卡操作信息，预计将场上的这张卡返回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 筛选条件：检查卡片是否为「童话动物·小小袋鼠」以外、可特殊召唤的「童话动物」怪兽
function c98416533.spfilter(c,e,tp)
	return c:IsSetCard(0x146) and not c:IsCode(98416533) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理流程：先将自身返回手卡；若成功回手卡，且己方至少有2个怪兽区空位、未受青眼精灵龙限制且卡组有2种以上其他「童话动物」怪兽，则可选特召同名最多1张的2只
function c98416533.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方卡组中全部可特殊召唤的其他「童话动物」怪兽组
	local g=Duel.GetMatchingGroup(c98416533.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 确认这张卡仍在连锁中，将其以效果返回手卡并确认成功进入手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		-- 检查己方主要怪兽区是否至少有2个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:GetClassCount(Card.GetCode)>1
		-- 询问己方是否从卡组特殊召唤2只「童话动物」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(98416533,2)) then  --"是否从卡组特殊召唤？"
		-- 中断效果处理，使后续的特殊召唤与前面的回到手卡视为不同时处理
		Duel.BreakEffect()
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从卡组选择2只卡名互不相同的「童话动物」怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将所选的2只「童话动物」怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件检查：确认当前回合玩家为己方
function c98416533.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为己方
	return Duel.GetTurnPlayer()==tp
end
-- ②效果的发动检测与连锁信息设置：确认己方怪兽区有空位且手卡中的这张卡可特召，并登记特殊召唤操作信息
function c98416533.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认己方主要怪兽区有空位且这张卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记连锁的特殊召唤操作信息，预计将手卡的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理流程：确认手卡的这张卡仍与效果有联系后将其特殊召唤到己方场上
function c98416533.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
