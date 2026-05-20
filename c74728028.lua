--エクシーズ・レセプション
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽相同等级的1只怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化。
function c74728028.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽相同等级的1只怪兽从手卡特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c74728028.target)
	e1:SetOperation(c74728028.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且手卡存在与之相同等级、可特殊召唤的怪兽的对象
function c74728028.filter1(c,e,tp)
	local lv=c:GetLevel()
	-- 检查怪兽等级大于0、表侧表示，且手卡中存在相同等级且可以特殊召唤的怪兽
	return lv>0 and c:IsFaceup() and Duel.IsExistingMatchingCard(c74728028.filter2,tp,LOCATION_HAND,0,1,nil,lv,e,tp)
end
-- 过滤手卡中等级与对象怪兽相同且可以特殊召唤的怪兽
function c74728028.filter2(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c74728028.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c74728028.filter1(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件1（表侧表示且手卡有同等级可特召怪兽）的怪兽作为对象
		and Duel.IsExistingTarget(c74728028.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c74728028.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c74728028.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只与对象怪兽相同等级的怪兽
	local g=Duel.SelectMatchingCard(tp,c74728028.filter2,tp,LOCATION_HAND,0,1,1,nil,tc:GetLevel(),e,tp)
	local sc=g:GetFirst()
	if sc then
		-- 将选择的怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2,true)
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e3,true)
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e4,true)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
