--マジックカード「死者蘇生」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个回合，这个效果特殊召唤的怪兽不能攻击，那个效果不能发动。
local s,id,o=GetID()
-- 定义并注册此卡的核心效果：创建魔法卡发动效果e1，类别为特殊召唤，取对象，可在自由时点发动；带有同名卡1回合1次的誓约次数限制，并设置提示时点、发动条件和处理函数，最后将效果注册到卡片本身。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义怪兽特殊召唤的合法性过滤函数：检查目标怪兽是否可以被当前效果e以表侧表示特殊召唤到玩家tp的场上（需满足召唤条件和苏生限制）。
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的取对象判定：若在检查对象（chkc非空），则确认该卡位于墓地且通过s.filter；若在发动合法检查（chk==0），则要求自己场上有特殊召唤空格且双方墓地存在至少1只可特殊召唤的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	-- 发动条件之一：确认玩家tp的场上主要怪兽区存在至少1个可用空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：确认以tp视角可选的双方墓地中存在至少1只满足s.filter条件的怪兽，能够作为效果对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家tp显示选择提示消息，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从自己或对方的墓地选择1只满足s.filter条件的怪兽，将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁操作信息：指定本连锁将进行1次特殊召唤，对象为已选择的怪兽g，用于给其他卡牌或效果响应该时点。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：取得对象怪兽，若对象仍与效果关联，则将其以表侧表示特殊召唤到自己场上；特殊召唤成功时，给该怪兽分别附加“不能攻击”和“不能发动效果”的封印效果；最后完成特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与当前效果关联（没有中途离场等），若是则通过特殊召唤步骤将其以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个回合，这个效果特殊召唤的怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))  --"「魔法卡「死者苏生」」的效果特殊召唤，不能攻击，不能把效果发动。"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那个效果不能发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- 结束特殊召唤步骤，完成整个特殊召唤处理，确保特殊召唤成功后的时点与诱发效果正确触发。
	Duel.SpecialSummonComplete()
end
