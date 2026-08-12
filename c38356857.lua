--グリム・リチュア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「冷酷遗式术师」以外的1只「遗式」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不用仪式怪兽不能攻击宣言。
function c38356857.initial_effect(c)
	-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(c38356857.rlevel)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「冷酷遗式术师」以外的1只「遗式」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不用仪式怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,38356857)
	e2:SetTarget(c38356857.sptg)
	e2:SetOperation(c38356857.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 设置该卡为水属性仪式怪兽时，其等级为自身等级左移16位加上该仪式怪兽等级的值。
function c38356857.rlevel(e,c)
	-- 获取该卡的等级数值，防止超过系统最大参数值。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 过滤函数，用于筛选满足「遗式」卡组且非本卡的怪兽，且可特殊召唤。
function c38356857.filter(c,e,tp)
	return c:IsSetCard(0x3a) and not c:IsCode(38356857) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位及卡组中是否存在符合条件的怪兽。
function c38356857.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的「遗式」怪兽。
		and Duel.IsExistingMatchingCard(c38356857.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽。
function c38356857.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只符合条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c38356857.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置一个永续效果，使玩家在回合结束前不能攻击宣言，除非使用仪式怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c38356857.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 该效果的目标为非仪式怪兽，使其不能攻击宣言。
function c38356857.atktg(e,c)
	return not c:IsType(TYPE_RITUAL)
end
