--焔虎
-- 效果：
-- 这张卡在墓地存在，自己场上没有怪兽存在的场合，自己的抽卡阶段时作为进行通常抽卡的代替才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
function c66499018.initial_effect(c)
	-- 这张卡在墓地存在，自己场上没有怪兽存在的场合，自己的抽卡阶段时作为进行通常抽卡的代替才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66499018,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c66499018.condition)
	e1:SetTarget(c66499018.target)
	e1:SetOperation(c66499018.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：必须在自己的回合，且自己场上没有怪兽存在时才能发动。
function c66499018.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，且自己场上的怪兽数量是否为0。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义效果发动目标与消耗函数：在发动时确认是否满足特召与抽卡条件，并执行代替抽卡的处理。
function c66499018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查阶段，判断玩家当前是否可以进行通常抽卡，且自己场上是否有空余的怪兽区域。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 使玩家放弃本回合的通常抽卡，作为发动效果的代替。
	aux.GiveUpNormalDraw(e,tp)
	-- 设置操作信息，向系统宣告此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数：将自身特殊召唤，并注册离场时除外的效果。
function c66499018.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将其在自己场上表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
