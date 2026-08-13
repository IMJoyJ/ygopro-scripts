--U.A.フラッグシップ・ディール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「超级运动员」怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。那之后，自己失去那只怪兽的等级×300基本分。
function c43658697.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「超级运动员」怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。那之后，自己失去那只怪兽的等级×300基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43658697+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43658697.target)
	e1:SetOperation(c43658697.activate)
	c:RegisterEffect(e1)
end
-- 过滤「超级运动员」怪兽，并确认其能被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c43658697.filter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前的合法性检测：自己场上主要怪兽区有空位，且卡组中存在至少1只满足条件的「超级运动员」怪兽。
function c43658697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格，确保特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可特殊召唤的「超级运动员」怪兽，作为发动条件之一。
		and Duel.IsExistingMatchingCard(c43658697.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：本次操作涉及从卡组特殊召唤1只怪兽，便于其他卡进行连锁判定与响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只「超级运动员」怪兽特殊召唤，给它附加效果无效、不能作为同调/超量素材的限制，再按等级扣除LP。
function c43658697.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用怪兽区空格，否则直接结束效果处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从卡组中选出1只符合条件的「超级运动员」怪兽，作为此次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c43658697.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选到了怪兽且该怪兽能通过特殊召唤步骤被成功特殊召唤（表侧表示），则进入后续附加效果处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不能作为同调·超量召唤的素材（其中“不能作为同调素材”部分）。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e4)
		-- 结束特殊召唤步骤，使之前用SpecialSummonStep预处理的特殊召唤正式完成。
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理，使后续LP扣除作为独立处理，不占用特殊召唤成功时的同一时点。
		Duel.BreakEffect()
		-- 获取当前玩家当前的基本分LP，为扣除LP做准备。
		local lp=Duel.GetLP(tp)
		-- 将玩家LP减去该特殊召唤怪兽的等级×300，即执行‘自己失去那只怪兽的等级×300基本分’。
		Duel.SetLP(tp,lp-tc:GetLevel()*300)
	end
end
