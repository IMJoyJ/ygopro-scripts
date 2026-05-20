--リサイコロ
-- 效果：
-- ①：以自己墓地1只「疾行机人」调整为对象才能发动。那只怪兽效果无效特殊召唤，掷1次骰子。那只特殊召唤的怪兽直到回合结束时变成和出现的数目相同等级。
-- ②：把墓地的这张卡除外才能发动。用自己场上的包含「疾行机人」调整的怪兽为素材，把1只风属性同调怪兽同调召唤。
function c85704698.initial_effect(c)
	-- ①：以自己墓地1只「疾行机人」调整为对象才能发动。那只怪兽效果无效特殊召唤，掷1次骰子。那只特殊召唤的怪兽直到回合结束时变成和出现的数目相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85704698.sptg)
	e1:SetOperation(c85704698.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。用自己场上的包含「疾行机人」调整的怪兽为素材，把1只风属性同调怪兽同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c85704698.syntg)
	e2:SetOperation(c85704698.synop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地可以特殊召唤的「疾行机人」调整怪兽
function c85704698.filter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择
function c85704698.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85704698.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「疾行机人」调整怪兽
		and Duel.IsExistingTarget(c85704698.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「疾行机人」调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85704698.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置掷骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果①的处理逻辑（特殊召唤、无效效果、掷骰子并改变等级）
function c85704698.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍符合条件，则将其以表侧表示特殊召唤（分步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那只怪兽效果无效特殊召唤，掷1次骰子。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		-- 让玩家掷1次骰子并获取出现的数目
		local lv=Duel.TossDice(tp,1)
		-- 那只特殊召唤的怪兽直到回合结束时变成和出现的数目相同等级。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(lv)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 过滤「疾行机人」调整怪兽
function c85704698.mfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER)
end
-- 同调素材合法性检查（必须包含「疾行机人」调整怪兽，且满足同调召唤条件）
function c85704698.syncheck(g,tp,syncard)
	-- 检查素材组中是否包含「疾行机人」调整，验证手卡同调素材，并判断是否能对目标怪兽进行同调召唤
	return g:IsExists(c85704698.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 过滤额外卡组中可以进行同调召唤的风属性同调怪兽
function c85704698.spfilter(c,tp,mg)
	if not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND)) then return false end
	-- 设置同调召唤素材等级计算的辅助校验函数，用于剪枝优化
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c85704698.syncheck,2,#mg,tp,c)
	-- 重置辅助校验函数
	aux.GCheckAdditional=nil
	return res
end
-- 效果②的发动准备与可行性检查
function c85704698.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家当前是否能够进行特殊召唤
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家场上的同调素材怪兽
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手卡中的怪兽（用于手卡同调效果的潜在素材）
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组是否存在可以使用当前素材进行同调召唤的风属性同调怪兽
		return Duel.IsExistingMatchingCard(c85704698.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 设置特殊召唤的操作信息，目标为额外卡组的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理逻辑（选择同调怪兽和素材并进行同调召唤）
function c85704698.synop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上的同调素材怪兽
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的怪兽（用于手卡同调效果的潜在素材）
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 获取额外卡组中所有可以使用当前素材同调召唤的风属性同调怪兽
	local g=Duel.GetMatchingGroup(c85704698.spfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c85704698.syncheck,false,2,#mg,tp,sc)
		-- 使用选定的素材对目标怪兽进行同调召唤
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
