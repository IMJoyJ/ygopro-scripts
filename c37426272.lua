--マテリアクトル・エクサレプト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看，从手卡丢弃1张其他卡才能发动。丢弃的卡以外的1只3星通常怪兽从自己的卡组·墓地加入手卡。那之后，可以把这张卡守备表示特殊召唤。
-- ②：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只3阶超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
local s,id,o=GetID()
-- 创建两个效果，分别为①和②效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看，从手卡丢弃1张其他卡才能发动。丢弃的卡以外的1只3星通常怪兽从自己的卡组·墓地加入手卡。那之后，可以把这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只3阶超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用处理，确认手卡中存在可丢弃的卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 确认手卡中存在可丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
	-- 获取实际丢弃的卡
	local g=Duel.GetOperatedGroup()
	-- 将丢弃的卡设为效果对象
	Duel.SetTargetCard(g)
end
-- 检索满足条件的3星通常怪兽的过滤函数
function s.thfilter(c)
	return c:IsLevel(3) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- ①效果的发动条件判断和操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，准备检索卡组或墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理流程，包括检索、加入手牌和特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	local ec=nil
	if tc:IsRelateToEffect(e) then ec=tc end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,ec)
	local hc=g:GetFirst()
	-- 判断是否成功将卡加入手牌
	if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 判断是否有足够的召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 询问是否特殊召唤此卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前连锁处理
			Duel.BreakEffect()
			-- 将此卡守备表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- ②效果的费用处理，将此卡丢入墓地
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡丢入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 攻击力提升效果的过滤函数
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRank(3)
end
-- ②效果的目标选择条件
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc)
		and chkc:GetControler()~=tp end
	-- 判断是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为对象
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理流程，为对象怪兽增加攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽增加1500攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
