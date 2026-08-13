--WW－ウィンター・ベル
-- 效果：
-- 调整＋调整以外的风属性怪兽1只以上
-- 「风魔女-冬铃」的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「风魔女」怪兽为对象才能发动。给与对方那只怪兽的等级×200伤害。
-- ②：自己·对方的战斗阶段以自己场上1只「风魔女」怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c14577226.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的风属性怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只「风魔女」怪兽为对象才能发动。给与对方那只怪兽的等级×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14577226,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14577226)
	e1:SetTarget(c14577226.damtg)
	e1:SetOperation(c14577226.damop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段以自己场上1只「风魔女」怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14577226,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,14577227)
	e2:SetCondition(c14577226.spcon)
	e2:SetTarget(c14577226.sptg)
	e2:SetOperation(c14577226.spop)
	c:RegisterEffect(e2)
end
-- 定义「风魔女」怪兽的筛选条件：持有「风魔女」字段且等级大于0。
function c14577226.damfilter(c)
	return c:IsSetCard(0xf0) and c:GetLevel()>0
end
-- ①效果的取对象处理函数：检查并选择自己墓地1只「风魔女」怪兽作为对象，并登记给与对方等级×200伤害的操作信息。
function c14577226.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14577226.damfilter(chkc) end
	-- 发动时（chk==0）确认自己墓地是否存在1只「风魔女」且等级大于0的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c14577226.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己墓地选择1只符合条件的「风魔女」怪兽作为本连锁的对象。
	local g=Duel.SelectTarget(tp,c14577226.damfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：给与对方玩家该对象等级×200的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetLevel()*200)
end
-- ①效果的伤害处理函数：对象仍与效果关联时，给与对方其等级×200的伤害。
function c14577226.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给与对方玩家对象怪兽等级×200的效果伤害。
		Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
	end
end
-- ②效果的发动条件判断函数：仅在战斗阶段内可以发动。
function c14577226.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- ②效果对象过滤函数：对象须为「风魔女」怪兽且等级大于0，并且手牌存在等级不高于其等级且可特殊召唤的怪兽。
function c14577226.tgfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 判定对象满足「风魔女」字段、等级大于0，且手牌中有符合条件的怪兽可特殊召唤。
	return c:IsSetCard(0xf0) and lv>0 and Duel.IsExistingMatchingCard(c14577226.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lv)
end
-- 手牌怪兽的过滤条件：等级不高于指定等级，且可以被特殊召唤（检查召唤条件，不检查苏生限制）。
function c14577226.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象处理函数：确认有可用区域且存在「风魔女」对象，选择自己场上1只「风魔女」怪兽，并登记从手牌特殊召唤的操作信息。
function c14577226.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c14577226.tgfilter(chkc,e,tp) end
	-- 发动时确认自己场上拥有至少1个可用主要怪兽区域，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上存在1只符合条件的「风魔女」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c14577226.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择效果的对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只符合条件的「风魔女」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c14577226.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：将从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理函数：若场上仍有空位且对象有效，从手牌特殊召唤1只等级不高于对象的怪兽，并让其本回合不能攻击。
function c14577226.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己场上没有可用怪兽区域，则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1只等级不高于对象等级且可以特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,c14577226.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
		local sg=g:GetFirst()
		-- 若选中的怪兽可以以表侧表示特殊召唤到自己的主要怪兽区域，则执行特殊召唤步骤。
		if sg and Duel.SpecialSummonStep(sg,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sg:RegisterEffect(e1)
		end
		-- 完成特殊召唤处理，触发特殊召唤成功时的时点。
		Duel.SpecialSummonComplete()
	end
end
