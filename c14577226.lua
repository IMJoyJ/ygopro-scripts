--WW－ウィンター・ベル
-- 效果：
-- 调整＋调整以外的风属性怪兽1只以上
-- 「风魔女-冬铃」的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「风魔女」怪兽为对象才能发动。给与对方那只怪兽的等级×200伤害。
-- ②：自己·对方的战斗阶段以自己场上1只「风魔女」怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c14577226.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只风属性的调整以外的怪兽
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
-- 过滤满足条件的墓地风属性怪兽
function c14577226.damfilter(c)
	return c:IsSetCard(0xf0) and c:GetLevel()>0
end
-- 设置伤害效果的发动条件和处理函数
function c14577226.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14577226.damfilter(chkc) end
	-- 检查是否满足发动条件，即自己墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c14577226.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c14577226.damfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时的伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetLevel()*200)
end
-- 设置伤害效果的处理函数
function c14577226.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对对方造成指定数值的伤害
		Duel.Damage(1-tp,tc:GetLevel()*200,REASON_EFFECT)
	end
end
-- 设置特殊召唤效果的发动条件
function c14577226.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤满足条件的场上风属性怪兽
function c14577226.tgfilter(c,e,tp)
	local lv=c:GetLevel()
	-- 检查是否满足发动条件，即场上有满足条件的怪兽且手牌中有满足条件的怪兽
	return c:IsSetCard(0xf0) and lv>0 and Duel.IsExistingMatchingCard(c14577226.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,lv)
end
-- 过滤满足条件的手牌怪兽
function c14577226.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和处理函数
function c14577226.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c14577226.tgfilter(chkc,e,tp) end
	-- 检查是否满足发动条件，即自己场上存在空位且存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件，即自己场上存在满足条件的怪兽
		and Duel.IsExistingTarget(c14577226.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的场上怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c14577226.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理时的特殊召唤信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置特殊召唤效果的处理函数
function c14577226.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足发动条件，即自己场上存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的手牌怪兽
		local g=Duel.SelectMatchingCard(tp,c14577226.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetLevel())
		local sg=g:GetFirst()
		-- 执行特殊召唤操作
		if sg and Duel.SpecialSummonStep(sg,0,tp,tp,false,false,POS_FACEUP) then
			-- 给特殊召唤的怪兽添加不能攻击的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sg:RegisterEffect(e1)
		end
		-- 完成特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
