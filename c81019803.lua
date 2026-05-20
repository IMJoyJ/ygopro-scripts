--うきうきメルフィーズ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
-- ②：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到额外卡组。那之后，可以从额外卡组把1只「童话动物」超量怪兽特殊召唤。
function c81019803.initial_effect(c)
	-- 为这张卡添加同调召唤手续（调整+1只以上调整以外的怪兽）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81019803,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,81019803)
	e1:SetTarget(c81019803.thtg)
	e1:SetOperation(c81019803.thop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽召唤·特殊召唤的场合或者这张卡被选择作为对方怪兽的攻击对象的场合才能发动。这张卡回到额外卡组。那之后，可以从额外卡组把1只「童话动物」超量怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81019803,1))  --"这张卡回到额外卡组"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,81019804)
	e2:SetCondition(c81019803.tdcon)
	e2:SetTarget(c81019803.tdtg)
	e2:SetOperation(c81019803.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetCondition(c81019803.tdcon2)
	c:RegisterEffect(e4)
end
-- 过滤场上表侧表示且能回到手牌的怪兽
function c81019803.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ①号效果的发动准备与目标选择
function c81019803.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81019803.thfilter(chkc) end
	-- 检查场上是否存在可以作为回到手牌对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c81019803.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81019803.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①号效果的实际处理
function c81019803.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤由特定玩家召唤或特殊召唤的怪兽
function c81019803.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 判断是否满足“对方把怪兽召唤·特殊召唤的场合”的发动条件
function c81019803.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81019803.cfilter,1,nil,1-tp)
end
-- 判断是否满足“这张卡被选择作为对方怪兽的攻击对象的场合”的发动条件
function c81019803.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ②号效果的发动准备
function c81019803.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() end
	-- 设置效果处理信息：将自身送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 过滤额外卡组中可以特殊召唤的「童话动物」超量怪兽
function c81019803.spfilter(c,e,tp)
	return c:IsSetCard(0x146) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查在自身离场后，是否有可用的额外怪兽区域空位用于特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②号效果的实际处理
function c81019803.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 将自身送回额外卡组，并确认是否成功回到额外卡组
		and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		-- 检查额外卡组是否存在可以特殊召唤的「童话动物」超量怪兽
		and Duel.IsExistingMatchingCard(c81019803.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否选择从额外卡组特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(81019803,2)) then  --"是否从额外卡组特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与回额外卡组不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的「童话动物」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c81019803.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		-- 将选择的「童话动物」超量怪兽在自身场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
