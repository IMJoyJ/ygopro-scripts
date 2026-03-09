--ダイナレスラー・エスクリマメンチ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「恐龙摔跤手」怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡在墓地存在，自己回合对方对怪兽的特殊召唤成功的场合，以自己墓地1只4星以下的「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
function c48372950.initial_effect(c)
	-- 效果原文内容：①：自己场上有「恐龙摔跤手」怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48372950,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c48372950.ntcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡在墓地存在，自己回合对方对怪兽的特殊召唤成功的场合，以自己墓地1只4星以下的「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48372950,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,48372950)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c48372950.spcon)
	e2:SetTarget(c48372950.sptg)
	e2:SetOperation(c48372950.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤满足条件的「恐龙摔跤手」怪兽（正面表示）
function c48372950.ntfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11a)
end
-- 规则层面作用：判断是否满足不用解放作召唤的条件（等级≥5且自己场上存在「恐龙摔跤手」怪兽）
function c48372950.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 规则层面作用：检查自己场上是否存在至少1只「恐龙摔跤手」怪兽（正面表示）
		and Duel.IsExistingMatchingCard(c48372950.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：过滤对方特殊召唤成功的怪兽（由对方玩家召唤）
function c48372950.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 规则层面作用：判断是否满足效果发动条件（当前回合玩家为发动者且对方有怪兽特殊召唤成功）
function c48372950.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查对方是否有至少1只怪兽被特殊召唤成功
	return Duel.GetTurnPlayer()==tp and eg:IsExists(c48372950.cfilter,1,nil,tp)
end
-- 规则层面作用：过滤满足条件的「恐龙摔跤手」怪兽（等级≤4且可特殊召唤）
function c48372950.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果发动时的选择目标（从自己墓地选择一只符合条件的「恐龙摔跤手」怪兽）
function c48372950.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48372950.spfilter(chkc,e,tp) end
	-- 规则层面作用：检查是否满足发动条件（墓地的卡能回手，场上存在空位，且有符合条件的目标怪兽）
	if chk==0 then return e:GetHandler():IsAbleToHand() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查是否存在至少1只符合条件的「恐龙摔跤手」怪兽在自己墓地
		and Duel.IsExistingTarget(c48372950.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择目标怪兽（从自己墓地选择一只符合条件的「恐龙摔跤手」怪兽）
	local g=Duel.SelectTarget(tp,c48372950.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置操作信息，指定将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 规则层面作用：设置操作信息，指定将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行效果处理流程（特殊召唤目标怪兽并把自身加入手卡）
function c48372950.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) then
		-- 规则层面作用：中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 规则层面作用：将自身送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
