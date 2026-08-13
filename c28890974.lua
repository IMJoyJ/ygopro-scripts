--光神化
-- 效果：
-- ①：从手卡把1只天使族怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成一半，结束阶段破坏。
function c28890974.initial_effect(c)
	-- ①：从手卡把1只天使族怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成一半，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28890974.target)
	e1:SetOperation(c28890974.activate)
	c:RegisterEffect(e1)
end
-- 定义手牌中可作为特殊召唤对象的怪兽的筛选条件：必须是天使族，且能够被玩家tp以本次效果e特殊召唤。
function c28890974.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：当chk==0时，检查自己场上是否有空余的主要怪兽区域，并且手牌中是否存在至少1只满足filter条件的怪兽；两者都满足才允许发动。
function c28890974.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定阶段，检查自己场上主要怪兽区是否存在空位（大于0），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动判定阶段，检查手牌中是否存在至少1只满足filter条件（天使族且可特殊召唤）的怪兽；与上一个条件共同决定效果可否发动。
		and Duel.IsExistingMatchingCard(c28890974.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本连锁的处理信息：此次效果属于特殊召唤，预计从手卡特殊召唤1只怪兽（处理时才选择对象，所以targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果处理：若场上仍有可用主要怪兽区，则让玩家从手牌选择1只满足条件的天使族怪兽；以表侧表示进行特殊召唤，若成功则使其攻击力变为原攻击力的一半（向上取整），并赋予其在结束阶段被破坏的效果；最后完成特殊召唤。
function c28890974.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己场上仍有可用的主要怪兽区域，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择卡片的消息提示，UI显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家tp从手牌中选出1张满足filter条件（天使族且可特殊召唤）的卡片作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c28890974.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local atk=tc:GetAttack()
		-- 执行分步特殊召唤：将选中的怪兽tc以表侧攻击表示特殊召唤到tp自己场上；若特殊召唤成功，则继续设置攻击力减半和结束阶段破坏的效果。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的攻击力变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 结束阶段破坏。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetOperation(c28890974.desop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetCountLimit(1)
			tc:RegisterEffect(e2)
		end
		-- 完成分步特殊召唤的收尾处理，宣告这次特殊召唤正式成功并触发相关时点。
		Duel.SpecialSummonComplete()
	end
end
-- 结束阶段的破坏处理函数：将持有该效果的怪兽（即被光神化特殊召唤的那只怪兽）破坏。
function c28890974.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏的方式将效果持有者（本效果所在的怪兽）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
