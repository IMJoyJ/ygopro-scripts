--異次元の一角戦士
-- 效果：
-- 这张卡不能通常召唤，把这张卡特殊召唤的回合自己不能通常召唤。这张卡在对方场上有怪兽存在，自己场上有调整表侧表示存在的场合可以特殊召唤。这个方法特殊召唤成功时，可以选择从游戏中除外的1只调整以外的3星以下的自己怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c95291684.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在对方场上有怪兽存在，自己场上有调整表侧表示存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c95291684.sprcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，可以选择从游戏中除外的1只调整以外的3星以下的自己怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95291684,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c95291684.spcon)
	e2:SetTarget(c95291684.sptg)
	e2:SetOperation(c95291684.spop)
	c:RegisterEffect(e2)
	-- 把这张卡特殊召唤的回合自己不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCost(c95291684.spcost)
	e3:SetOperation(c95291684.spcop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的调整怪兽
function c95291684.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 特殊召唤规则的判定条件
function c95291684.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定对方场上是否有怪兽、自己场上是否有可用怪兽区域以及自己场上是否存在表侧表示的调整怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c95291684.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判定是否是通过自身特殊召唤规则特殊召唤成功
function c95291684.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：除外区表侧表示的、3星以下的、调整以外的、可以特殊召唤的自己怪兽
function c95291684.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(3) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择与判定
function c95291684.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c95291684.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定除外区是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c95291684.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c95291684.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行处理
function c95291684.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。把这张卡特殊召唤的回合自己不能通常召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
-- 特殊召唤的代价判定：本回合自己没有进行过通常召唤
function c95291684.spcost(e,c,tp)
	-- 判定本回合通常召唤的次数是否为0
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 特殊召唤成功时，注册本回合不能通常召唤的限制
function c95291684.spcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 把这张卡特殊召唤的回合自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册本回合不能进行通常召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 给玩家注册本回合不能进行通常召唤（放置）的效果
	Duel.RegisterEffect(e2,tp)
end
