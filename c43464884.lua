--妖海のアウトロール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是兽战士族怪兽不能特殊召唤。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只兽战士族怪兽为对象才能发动。这张卡的属性·等级直到回合结束时变成和那只怪兽相同。
-- ②：自己主要阶段才能发动。把持有和这张卡相同属性·等级的1只兽战士族怪兽从手卡特殊召唤。
function c43464884.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只兽战士族怪兽为对象才能发动。这张卡的属性·等级直到回合结束时变成和那只怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43464884,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,43464884)
	e1:SetCost(c43464884.cost)
	e1:SetTarget(c43464884.cgtg)
	e1:SetOperation(c43464884.cgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。把持有和这张卡相同属性·等级的1只兽战士族怪兽从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43464884,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,43464885)
	e3:SetCost(c43464884.cost)
	e3:SetTarget(c43464884.sptg)
	e3:SetOperation(c43464884.spop)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用于检测该回合是否进行了非兽战士族怪兽的特殊召唤
	Duel.AddCustomActivityCounter(43464884,ACTIVITY_SPSUMMON,c43464884.counterfilter)
end
-- 计数器过滤条件：被特殊召唤的怪兽是表侧表示的兽战士族怪兽
function c43464884.counterfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsFaceup()
end
-- 限制特殊召唤非兽战士族怪兽的誓约效果
function c43464884.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk为0时，检查玩家本回合是否特殊召唤过非兽战士族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(43464884,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是兽战士族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43464884.splimit)
	-- 将不能特殊召唤非兽战士族怪兽的限制效果注册给发动效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤条件：限制不能特殊召唤非兽战士族怪兽
function c43464884.splimit(e,c)
	return not c:IsRace(RACE_BEASTWARRIOR)
end
-- 等级/属性改变效果的目标过滤：墓地中等级在1以上且与自身属性或等级不同的兽战士族怪兽
function c43464884.cgfilter(c,mc)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsLevelAbove(1) and not (c:IsLevel(mc:GetLevel()) and c:IsAttribute(mc:GetAttribute()))
end
-- 等级/属性改变效果的靶向目标选择
function c43464884.cgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43464884.cgfilter(chkc,c) end
	-- chk为0时，检查墓地中是否存在可作为对象的符合条件的兽战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c43464884.cgfilter,tp,LOCATION_GRAVE,0,1,nil,c) end
	-- 设置提示信息：选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地1只符合条件的兽战士族怪兽并作为效果的对象
	Duel.SelectTarget(tp,c43464884.cgfilter,tp,LOCATION_GRAVE,0,1,1,nil,c)
end
-- 等级/属性改变效果的具体处理
function c43464884.cgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个也是唯一的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		local lv=tc:GetLevel()
		local att=tc:GetAttribute()
		-- 等级直到回合结束时变成和那只怪兽相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		c:RegisterEffect(e2)
	end
end
-- 手卡特殊召唤效果的过滤条件：手卡中与自身等级和属性均相同的可特殊召唤的兽战士族怪兽
function c43464884.spfilter(c,e,tp,mc)
	return c:IsLevel(mc:GetLevel()) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(mc:GetAttribute()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 手卡特殊召唤效果的发动判定与准备
function c43464884.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk为0时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c43464884.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置包含从手卡特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手卡特殊召唤效果的具体处理
function c43464884.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有空余的怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 设置提示信息：选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中1只符合条件的兽战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c43464884.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
