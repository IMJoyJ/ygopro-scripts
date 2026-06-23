--電脳堺門－玄武
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有其他的「电脑堺门」卡存在的场合，自己·对方的战斗阶段，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「电脑堺」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，选1张手卡送去墓地。
function c18249921.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18249921+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- ①：自己场上有其他的「电脑堺门」卡存在的场合，自己·对方的战斗阶段，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18249921,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,18249922)
	e2:SetCondition(c18249921.cpcon)
	e2:SetTarget(c18249921.cptg)
	e2:SetOperation(c18249921.cpop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「电脑堺」怪兽为对象才能发动。那只怪兽效果无效特殊召唤。那之后，选1张手卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18249921,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,18249923)
	e3:SetCondition(c18249921.spcon)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c18249921.sptg)
	e3:SetOperation(c18249921.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有其他表侧表示的「电脑堺门」卡
function c18249921.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114e)
end
-- 判断是否满足①效果的发动条件：当前阶段为战斗阶段开始到战斗阶段结束，并且自己场上存在其他「电脑堺门」卡
function c18249921.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回当前阶段是否为战斗阶段开始到战斗阶段结束，并且自己场上存在其他「电脑堺门」卡
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and Duel.IsExistingMatchingCard(c18249921.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 过滤函数，用于判断目标怪兽是否可以改变表示形式
function c18249921.cpfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 设置①效果的目标选择函数和条件检查
function c18249921.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18249921.cpfilter(chkc) end
	-- 检查是否满足①效果的发动条件：场上存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c18249921.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c18249921.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示形式变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的处理函数
function c18249921.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽改变表示形式为表侧守备、表侧守备、表侧攻击、表侧攻击
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 判断是否满足②效果的发动条件：当前回合玩家为发动者，并且当前阶段为主要阶段1或主要阶段2
function c18249921.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 返回当前回合玩家为发动者，并且当前阶段为主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤函数，用于判断墓地中的「电脑堺」怪兽是否可以特殊召唤
function c18249921.spfilter(c,e,tp)
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置②效果的目标选择函数和条件检查
function c18249921.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c18249921.spfilter(chkc,e,tp) end
	-- 检查是否满足②效果的发动条件：有足够召唤区域，墓地存在「电脑堺」怪兽，手牌中有可送去墓地的卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c18249921.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查是否满足②效果的发动条件：手牌中有可送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c18249921.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息，送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数
function c18249921.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 特殊召唤目标怪兽
	local res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	if res then
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 获取手牌中可送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_HAND,0,nil)
	if res and #g>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
