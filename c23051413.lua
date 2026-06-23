--ナチュル・スタッグ
-- 效果：
-- 这张卡进行攻击的战斗步骤时以及伤害步骤时对方把魔法·陷阱·效果怪兽的效果发动时，选择自己墓地存在的1只名字带有「自然」的怪兽才能发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
function c23051413.initial_effect(c)
	-- 创建一个诱发即时效果，可以在伤害步骤时对方发动魔法·陷阱·效果怪兽的效果时发动，选择自己墓地1只名字带有「自然」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23051413,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c23051413.spcon)
	e1:SetTarget(c23051413.sptg)
	e1:SetOperation(c23051413.spop)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数，用于判断是否满足发动条件。
function c23051413.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方玩家（rp）是否为当前玩家的对手，并且当前卡是否为攻击怪兽。
	return rp==1-tp and e:GetHandler()==Duel.GetAttacker()
end
-- 过滤函数，用于筛选墓地里名字带有「自然」且可以特殊召唤的怪兽。
function c23051413.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动目标选择函数，用于选择满足条件的墓地怪兽。
function c23051413.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23051413.filter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c23051413.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果的目标。
	local g=Duel.SelectTarget(tp,c23051413.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽数量和目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的处理函数，用于执行特殊召唤操作。
function c23051413.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
