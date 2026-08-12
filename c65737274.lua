--ドラゴラド
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只攻击力1000以下的通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：1回合1次，把自己场上1只龙族怪兽解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时等级变成8星，攻击力上升800。
function c65737274.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只攻击力1000以下的通常怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65737274,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c65737274.sptg)
	e1:SetOperation(c65737274.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1只龙族怪兽解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时等级变成8星，攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65737274,1))  --"等级攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c65737274.lvcost)
	e2:SetTarget(c65737274.lvtg)
	e2:SetOperation(c65737274.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：攻击力1000以下且可以守备表示特殊召唤的通常怪兽
function c65737274.spfilter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备（检查是否满足发动条件、选择墓地的目标怪兽并设置特殊召唤的操作信息）
function c65737274.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65737274.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingTarget(c65737274.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65737274.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含目标怪兽和数量1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理（将选择的目标怪兽守备表示特殊召唤）
function c65737274.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：龙族怪兽，且解放该卡后场上仍存在可作为等级/攻击力变化对象的表侧表示怪兽
function c65737274.cfilter(c,tp)
	-- 检查该卡是否为龙族，且场上是否存在除该卡以外的、满足等级变化条件的表侧表示怪兽
	return c:IsRace(RACE_DRAGON) and Duel.IsExistingTarget(c65737274.lvfilter,tp,LOCATION_MZONE,0,1,c)
end
-- 过滤条件：表侧表示、有等级且等级不为8的怪兽
function c65737274.lvfilter(c)
	return c:IsFaceup() and not c:IsLevel(8) and c:IsLevelAbove(1)
end
-- 效果②的发动代价处理（解放自己场上1只龙族怪兽）
function c65737274.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为发动代价解放的龙族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c65737274.cfilter,1,nil,tp) end
	-- 选择自己场上1只满足条件的龙族怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c65737274.cfilter,1,1,nil,tp)
	-- 将选择的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动准备（选择场上1只表侧表示怪兽作为效果对象）
function c65737274.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65737274.lvfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只满足等级变化条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c65737274.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理（使目标怪兽直到回合结束时等级变成8星，攻击力上升800）
function c65737274.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsLevel(8) then
		-- 那只怪兽直到回合结束时等级变成8星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(800)
		tc:RegisterEffect(e2)
	end
end
