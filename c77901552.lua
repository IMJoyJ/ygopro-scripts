--聖刻龍－トフェニドラゴン
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的回合，这张卡不能攻击。
-- ②：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
function c77901552.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c77901552.hspcon)
	e1:SetOperation(c77901552.hspop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合发动。从自己的手卡·卡组·墓地选1只龙族通常怪兽，攻击力·守备力变成0特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77901552,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(c77901552.sptg)
	e2:SetOperation(c77901552.spop)
	c:RegisterEffect(e2)
end
-- 自身特殊召唤规则的条件：自己场上没有怪兽，对方场上有怪兽存在，且自己场上有可用的怪兽区域。
function c77901552.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域，且自己场上的怪兽数量为0。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量不为0。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 自身特殊召唤成功时的处理：给自身添加该回合不能攻击的效果。
function c77901552.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡、卡组、墓地中可以特殊召唤的龙族通常怪兽。
function c77901552.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：设置特殊召唤的操作信息（从手卡、卡组、墓地特殊召唤1只怪兽）。
function c77901552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，数量为1，范围为手卡、卡组、墓地（0x13）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果②的效果处理：从手卡、卡组、墓地选1只龙族通常怪兽，将其攻击力·守备力变成0特殊召唤。
function c77901552.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地（受王家之谷影响）中选择1只满足条件的龙族通常怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c77901552.spfilter),tp,0x13,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 尝试将选中的怪兽以表侧表示特殊召唤。
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力变成0
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
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
