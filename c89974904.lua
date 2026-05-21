--シンクロコール
-- 效果：
-- ①：以自己墓地1只怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用包含那只怪兽的自己场上的怪兽为素材把1只龙族·恶魔族的暗属性同调怪兽同调召唤。
function c89974904.initial_effect(c)
	-- ①：以自己墓地1只怪兽为对象才能发动。那只怪兽效果无效特殊召唤，只用包含那只怪兽的自己场上的怪兽为素材把1只龙族·恶魔族的暗属性同调怪兽同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c89974904.target)
	e1:SetOperation(c89974904.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中可以以指定怪兽为素材进行同调召唤的暗属性龙族·恶魔族同调怪兽
function c89974904.cfilter(c,tc)
	return c:IsRace(RACE_DRAGON+RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsSynchroSummonable(tc)
end
-- 过滤墓地中可以特殊召唤，且召唤后能作为素材同调召唤额外卡组中暗属性龙族·恶魔族同调怪兽的怪兽
function c89974904.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_SYNCHRO_MATERIAL,tp,false,false)
		-- 检查额外卡组是否存在至少1只以该怪兽为素材可同调召唤的暗属性龙族·恶魔族同调怪兽
		and Duel.IsExistingMatchingCard(c89974904.cfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 效果发动的目标选择与合法性检测
function c89974904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89974904.spfilter(chkc,e,tp) end
	-- 检查玩家是否能进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有可用于特殊召唤怪兽的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为同调素材特召的怪兽
		and Duel.IsExistingTarget(c89974904.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c89974904.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤2只怪兽的操作信息（墓地特召1只，额外同调召唤1只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 效果处理的执行函数
function c89974904.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤（作为同调素材）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,SUMMON_VALUE_SYNCHRO_MATERIAL,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
		-- 刷新场地信息，确保后续同调召唤的素材状态正确
		Duel.AdjustAll()
		if not tc:IsLocation(LOCATION_MZONE) then return end
		-- 获取额外卡组中，只用包含该怪兽的自己场上怪兽为素材可以同调召唤的暗属性龙族·恶魔族同调怪兽
		local g=Duel.GetMatchingGroup(c89974904.cfilter,tp,LOCATION_EXTRA,0,nil,tc)
		if g:GetCount()>0 then
			-- 提示玩家选择要进行同调召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 强制以该怪兽为素材，对选定的怪兽进行同调召唤
			Duel.SynchroSummon(tp,sg:GetFirst(),tc)
		end
	end
end
