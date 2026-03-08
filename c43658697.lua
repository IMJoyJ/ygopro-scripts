--U.A.フラッグシップ・ディール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「超级运动员」怪兽特殊召唤。这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。那之后，自己失去那只怪兽的等级×300基本分。
function c43658697.initial_effect(c)
	-- 效果作用：设置卡名限制、发动条件、特殊召唤目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43658697+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43658697.target)
	e1:SetOperation(c43658697.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选「超级运动员」怪兽且可特殊召唤
function c43658697.filter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：判断是否满足发动条件（有空位且卡组有符合条件的怪兽）
function c43658697.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果处理：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果处理：判断卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c43658697.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果处理：设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：执行特殊召唤及后续处理
function c43658697.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果处理：从卡组选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c43658697.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 效果处理：开始特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- ①：这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- ①：这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- ①：这个效果特殊召唤的怪兽不能作为同调·超量召唤的素材，效果无效化。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e4)
		-- 效果处理：完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 效果处理：中断当前效果
		Duel.BreakEffect()
		-- 效果处理：获取当前基本分
		local lp=Duel.GetLP(tp)
		-- 效果处理：扣除特殊召唤怪兽等级×300的基本分
		Duel.SetLP(tp,lp-tc:GetLevel()*300)
	end
end
