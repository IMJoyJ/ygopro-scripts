--常夏のカミナリサマー
-- 效果：
-- 雷族怪兽2只
-- ①：对方回合1次，丢弃1张手卡，以连接怪兽以外的自己墓地1只雷族怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c38406364.initial_effect(c)
	-- 为这张卡添加连接召唤手续：使用2只雷族怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_THUNDER),2,2)
	c:EnableReviveLimit()
	-- ①：对方回合1次，丢弃1张手卡，以连接怪兽以外的自己墓地1只雷族怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(38406364,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38406364.spcon)
	e1:SetCost(c38406364.spcost)
	e1:SetTarget(c38406364.sptg)
	e1:SetOperation(c38406364.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：仅当这张卡的控制者处于对方回合时，该效果才能发动。
function c38406364.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是自己（tp），即满足“对方回合”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义效果发动代价：从手牌丢弃1张卡作为发动代价。
function c38406364.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认自己手牌中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：让自己从手牌选择1张可丢弃的卡丢弃，丢弃原因包含代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤对象筛选条件：自己墓地的雷族怪兽、不是连接怪兽、并且可以被特殊召唤到这张卡所连接区的自己场上。
function c38406364.filter(c,e,tp,zone)
	return c:IsRace(RACE_THUNDER) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 目标选择函数：获取这张卡在自己场上的连接区域（仅主怪兽区），并检查合法发动条件；若合法则从墓地选择1只符合条件的雷族怪兽作为效果对象。
function c38406364.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38406364.filter(chkc,e,tp,zone) end
	-- 发动合法性检查之一：确认自己场上存在至少1个可用的主要怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查之二：确认自己墓地存在至少1只满足筛选条件且能成为效果对象的雷族怪兽。
		and Duel.IsExistingTarget(c38406364.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 向操作者显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的符合条件的雷族怪兽中选择1只作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c38406364.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置本次操作的信息：效果处理时将把所选择的对象进行1次特殊召唤，供其他卡片的连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理：从对象中取得目标怪兽，若目标仍与效果相关且这张卡的连接区域仍可用，则将目标怪兽特殊召唤到这张卡所连接区的自己场上。
function c38406364.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽以表侧表示特殊召唤到这张卡连接区对应的自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
