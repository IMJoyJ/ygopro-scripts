--白棘鱏
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只水属性怪兽丢弃，从手卡特殊召唤。
-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。
function c49930315.initial_effect(c)
	-- ①：这张卡可以把手卡1只水属性怪兽丢弃，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49930315+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c49930315.spcon)
	e1:SetTarget(c49930315.sptg)
	e1:SetOperation(c49930315.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49930315,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,49930316)
	e2:SetCondition(c49930315.tncon)
	e2:SetOperation(c49930315.tnop)
	c:RegisterEffect(e2)
end
c49930315.treat_itself_tuner=true
-- 过滤函数，用于判断手牌中是否存在满足条件的水属性可丢弃怪兽。
function c49930315.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 特殊召唤的条件函数，检查是否满足特殊召唤所需条件（有空场且手牌有水属性怪兽）。
function c49930315.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家场上是否有足够的怪兽区域可用于特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在至少1只水属性怪兽。
		and Duel.IsExistingMatchingCard(c49930315.cfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤的目标选择函数，用于选择要丢弃的手牌。
function c49930315.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的水属性手牌组。
	local g=Duel.GetMatchingGroup(c49930315.cfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送提示信息“请选择要丢弃的手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的操作函数，将选定的卡送去墓地。
function c49930315.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡以丢弃和特殊召唤的原因送去墓地。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- 调整效果的发动条件函数，判断该卡是否从墓地被特殊召唤成功。
function c49930315.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 调整效果的发动操作函数，使该卡在本回合内获得调整属性。
function c49930315.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 为该卡添加调整（TYPE_TUNER）属性，使其在本回合内当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
