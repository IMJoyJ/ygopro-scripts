--爆走軌道フライング・ペガサス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「爆走轨道 冲天飞马」以外的自己墓地1只机械族·地属性怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
-- ②：以自己场上1只其他的表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不用超量怪兽不能攻击宣言）。那只怪兽和这张卡之内的1只的等级变成和另1只的等级相同。
function c88875132.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「爆走轨道 冲天飞马」以外的自己墓地1只机械族·地属性怪兽为对象才能发动。那只怪兽效果无效守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88875132,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,88875132)
	e1:SetTarget(c88875132.sptg)
	e1:SetOperation(c88875132.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只其他的表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不用超量怪兽不能攻击宣言）。那只怪兽和这张卡之内的1只的等级变成和另1只的等级相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88875132,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,88875133)
	e3:SetCost(c88875132.lvcost)
	e3:SetTarget(c88875132.lvtg)
	e3:SetOperation(c88875132.lvop)
	c:RegisterEffect(e3)
	-- 注册用于检测非超量怪兽攻击宣言的自定义活动计数器
	Duel.AddCustomActivityCounter(88875132,ACTIVITY_ATTACK,c88875132.counterfilter)
end
-- 过滤函数：判定怪兽是否为超量怪兽
function c88875132.counterfilter(c)
	return c:IsType(TYPE_XYZ)
end
-- 过滤函数：筛选「爆走轨道 冲天飞马」以外的自己墓地1只地属性·机械族且可以守备表示特殊召唤的怪兽
function c88875132.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and not c:IsCode(88875132)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的目标选择与判定函数
function c88875132.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88875132.spfilter(chkc,e,tp) end
	-- 判定自己墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88875132.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判定自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88875132.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的特殊召唤效果执行函数
function c88875132.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍符合效果，并尝试将其以表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 那只怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果②的代价判定与执行函数（限制本回合的攻击宣言）
function c88875132.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定本回合自己是否未进行过非超量怪兽的攻击宣言
	if chk==0 then return Duel.GetCustomActivityCount(88875132,tp,ACTIVITY_ATTACK)==0 end
	-- 以自己场上1只其他的表侧表示怪兽为对象才能发动（这个效果发动的回合，自己不用超量怪兽不能攻击宣言）。那只怪兽和这张卡之内的1只的等级变成和另1只的等级相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c88875132.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制攻击宣言的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判定怪兽是否不是超量怪兽
function c88875132.atktg(e,c)
	return not c:IsType(TYPE_XYZ)
end
-- 过滤函数：筛选自己场上1只表侧表示、等级在1以上且等级与自身不同的怪兽
function c88875132.lvfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 效果②的目标选择与判定函数
function c88875132.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88875132.lvfilter(chkc,lv) end
	-- 判定自身等级是否大于0，且自己场上是否存在其他满足条件的表侧表示怪兽
	if chk==0 then return lv>0 and Duel.IsExistingTarget(c88875132.lvfilter,tp,LOCATION_MZONE,0,1,c,lv) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只其他的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c88875132.lvfilter,tp,LOCATION_MZONE,0,1,1,c,lv)
end
-- 效果②的等级变化效果执行函数
function c88875132.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsLevel(c:GetLevel()) then
		local g=Group.FromCards(c,tc)
		-- 提示玩家选择要作为目标等级的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88875132,2))  --"请选择拥有目标等级的怪兽"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		g:RemoveCard(tc)
		-- 那只怪兽和这张卡之内的1只的等级变成和另1只的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetLevel())
		g:GetFirst():RegisterEffect(e1)
	end
end
