--白棘鱏
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只水属性怪兽丢弃，从手卡特殊召唤。
-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。
function c49930315.initial_effect(c)
	-- ①：这张卡可以把手卡1只水属性怪兽丢弃，从手卡特殊召唤。（这个卡名的①的方法的特殊召唤1回合只能有1次）
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
	-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。（②的效果1回合只能使用1次）
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
-- 过滤函数：判断手牌中的怪兽是否满足水属性且能够作为丢弃代价被丢弃，用于挑选①效果要丢弃的水属性怪兽。
function c49930315.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- ①效果的特殊召唤规则条件：被特殊召唤的这张卡需要自己场上有可用怪兽区域，且手牌中存在自身以外可丢弃的水属性怪兽作为代价。
function c49930315.spcon(e,c)
	if c==nil then return true end
	-- 确认这张卡的控制者场上存在可用的主要怪兽区域空格，用于从手卡特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查控制者手牌中是否存在至少1张满足水属性且可丢弃的怪兽（自身除外），作为①效果的丢弃代价。
		and Duel.IsExistingMatchingCard(c49930315.cfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 选择要丢弃的水属性怪兽作为特殊召唤的代价：生成候选集合、给出丢弃提示、让玩家选择1张，并将选中的卡存入效果对象以备后续处理。
function c49930315.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌中所有满足水属性且可丢弃、且不是这张卡自身的怪兽集合，作为可选的丢弃代价候选。
	local g=Duel.GetMatchingGroup(c49930315.cfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家显示选择提示，提示内容为“请选择要丢弃的手牌”，用于选择丢弃的水属性怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果特殊召唤的实际代价处理：取出之前选定的怪兽并丢弃到墓地，从而完成从手卡特殊召唤的手续。
function c49930315.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的水属性怪兽以丢弃+特殊召唤相关原因送入墓地，作为从手卡特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- ②效果的发动条件：这张卡特殊召唤成功时，其特殊召唤前所在位置为墓地，即“从墓地的特殊召唤成功”的场合。
function c49930315.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ②效果处理：若这张卡仍与效果关联，则赋予它“视为调整”的效果，让这张卡在这个回合当作调整使用，持续到结束阶段。
function c49930315.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
