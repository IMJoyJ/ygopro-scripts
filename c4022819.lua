--聖刻龍－アセトドラゴン
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1000。1回合1次，选择场上1只龙族的通常怪兽才能发动。场上的全部名字带有「圣刻」的怪兽的等级直到结束阶段时变成和选择的怪兽相同等级。此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤。
function c4022819.initial_effect(c)
	-- 这个效果使得该卡可以不用解放进行召唤，且召唤成功后原本攻击力变为1000
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4022819,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c4022819.ntcon)
	e1:SetOperation(c4022819.ntop)
	c:RegisterEffect(e1)
	-- 1回合1次，选择场上1只龙族的通常怪兽才能发动。场上的全部名字带有「圣刻」的怪兽的等级直到结束阶段时变成和选择的怪兽相同等级
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4022819,1))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c4022819.lvtg)
	e2:SetOperation(c4022819.lvop)
	c:RegisterEffect(e2)
	-- 此外，这张卡被解放时，从自己的手卡·卡组·墓地选1只龙族的通常怪兽，攻击力·守备力变成0特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4022819,2))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(c4022819.sptg)
	e3:SetOperation(c4022819.spop)
	c:RegisterEffect(e3)
end
-- 判断该卡是否满足不需解放召唤的条件：召唤时不需要解放，且等级不低于5，且场上存在空位
function c4022819.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足不需解放召唤的条件：召唤时不需要解放，且等级不低于5，且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 将该卡的原本攻击力设置为1000
function c4022819.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 将该卡的原本攻击力设置为1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤出场上表侧表示的龙族通常怪兽
function c4022819.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON)
end
-- 选择目标：选择场上1只表侧表示的龙族通常怪兽
function c4022819.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4022819.lvfilter(chkc) end
	-- 判断是否满足选择目标的条件：场上存在1只表侧表示的龙族通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c4022819.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的龙族通常怪兽作为目标
	Duel.SelectTarget(tp,c4022819.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 过滤出场上表侧表示的「圣刻」怪兽
function c4022819.lvfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and c:IsLevelAbove(0)
end
-- 将场上所有「圣刻」怪兽的等级改为与目标怪兽相同
function c4022819.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 获取场上所有「圣刻」怪兽的集合
	local g=Duel.GetMatchingGroup(c4022819.lvfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,tc)
	local lc=g:GetFirst()
	local lv=tc:GetLevel()
	while lc~=nil do
		-- 将目标怪兽的等级设置为与目标怪兽相同
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
-- 过滤出可以特殊召唤的龙族通常怪兽
function c4022819.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的效果处理信息
function c4022819.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 从手卡·卡组·墓地选择1只龙族通常怪兽特殊召唤，并将其攻击力和守备力设为0
function c4022819.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只龙族通常怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4022819.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试特殊召唤目标怪兽
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将目标怪兽的攻击力设置为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
