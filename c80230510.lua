--埋葬されし生け贄
-- 效果：
-- ①：这个回合，自己作需要怪兽2只解放的上级召唤的场合只有1次，可以不把怪兽2只解放而从自己·对方的墓地把怪兽各1只除外来上级召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c80230510.initial_effect(c)
	-- ①：这个回合，自己作需要怪兽2只解放的上级召唤的场合只有1次，可以不把怪兽2只解放而从自己·对方的墓地把怪兽各1只除外来上级召唤。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c80230510.target)
	e1:SetOperation(c80230510.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的Target函数，用于检查发动条件。
function c80230510.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未发动过此卡的效果。
	if chk==0 then return Duel.GetFlagEffect(tp,80230510)==0 end
end
-- 定义卡片发动的Operation函数，注册替代上级召唤/放置的效果以及不能特殊召唤的限制。
function c80230510.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己作需要怪兽2只解放的上级召唤的场合只有1次，可以不把怪兽2只解放而从自己·对方的墓地把怪兽各1只除外来上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80230510,0))  --"把墓地怪兽除外上级召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(c80230510.otcon)
	e1:SetTarget(c80230510.ottg)
	e1:SetOperation(c80230510.otop)
	e1:SetCountLimit(1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册允许不解放怪兽而进行上级召唤的规则效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	-- 注册允许不解放怪兽而进行上级放置的规则效果。
	Duel.RegisterEffect(e2,tp)
	-- 为玩家注册已发动过此卡效果的标识，持续到回合结束。
	Duel.RegisterFlagEffect(tp,80230510,RESET_PHASE+PHASE_END,0,1)
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	-- 注册直到回合结束时自己不能把怪兽特殊召唤的限制效果。
	Duel.RegisterEffect(e3,tp)
end
-- 过滤可以作为Cost除外的墓地怪兽。
function c80230510.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义替代上级召唤的条件函数，检查是否满足解放怪兽数量、怪兽区域空位以及双方墓地存在可除外怪兽的条件。
function c80230510.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查召唤该怪兽所需的解放怪兽数量是否在2只以内，且自己场上有可用的怪兽区域。
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以除外的怪兽。
		and Duel.IsExistingMatchingCard(c80230510.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否存在至少1只可以除外的怪兽。
		and Duel.IsExistingMatchingCard(c80230510.rmfilter,tp,0,LOCATION_GRAVE,1,nil)
end
-- 定义替代上级召唤的对象过滤函数，限定为需要2只解放的怪兽。
function c80230510.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2
end
-- 定义替代上级召唤的操作函数，执行从双方墓地除外怪兽并重置使用次数的操作。
function c80230510.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只怪兽。
	local g1=Duel.SelectMatchingCard(tp,c80230510.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1只怪兽。
	local g2=Duel.SelectMatchingCard(tp,c80230510.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 将选中的双方墓地怪兽正面表示除外作为召唤的代替代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 手动重置玩家的FlagEffect，使该替代召唤效果本回合不能再次使用。
	Duel.ResetFlagEffect(tp,80230510)
	c:SetMaterial(nil)
end
