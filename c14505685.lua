--サイバース・コンバーター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上的怪兽只有电子界族怪兽的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤成功时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到回合结束时变成电子界族。
function c14505685.initial_effect(c)
	-- ①：自己场上的怪兽只有电子界族怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14505685+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c14505685.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到回合结束时变成电子界族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14505685,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c14505685.rctg)
	e2:SetOperation(c14505685.rcop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在非电子界族的表侧表示怪兽
function c14505685.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_CYBERSE)
end
-- 特殊召唤条件函数，判断是否满足从手卡特殊召唤的条件
function c14505685.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否至少存在1张怪兽卡
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查玩家场上是否不存在非电子界族的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(c14505685.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断场上是否存在可变为电子界族的表侧表示怪兽
function c14505685.rcfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_CYBERSE)
end
-- 选择目标怪兽效果的处理函数
function c14505685.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14505685.rcfilter(chkc) end
	-- 判断是否满足选择目标怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c14505685.rcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c14505685.rcfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数
function c14505685.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽的种族变为电子界族，直到回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_CYBERSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
