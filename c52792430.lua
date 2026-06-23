--捕食植物スピノ・ディオネア
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害计算后才能发动。从卡组把「捕食植物 捕蝇草棘龙」以外的1只「捕食植物」怪兽特殊召唤。
function c52792430.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52792430,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c52792430.cttg)
	e1:SetOperation(c52792430.ctop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害计算后才能发动。从卡组把「捕食植物 捕蝇草棘龙」以外的1只「捕食植物」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52792430,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c52792430.spcon)
	e3:SetTarget(c52792430.sptg)
	e3:SetOperation(c52792430.spop)
	c:RegisterEffect(e3)
end
-- 选择对方场上1只表侧表示的怪兽作为对象，该怪兽可以放置捕食指示物。
function c52792430.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	-- 检查是否存在满足条件的目标怪兽（即对方场上1只可以放置捕食指示物的表侧表示怪兽）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 提示玩家选择一张表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为对象，该怪兽可以放置捕食指示物。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 将目标怪兽的等级变为1星（如果该怪兽已放置捕食指示物且等级高于1）。
function c52792430.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
		-- 创建一个改变目标怪兽等级的效果，使其等级变为1。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c52792430.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否拥有捕食指示物。
function c52792430.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 判断战斗中对方怪兽的等级是否小于等于自身等级且处于战斗状态。
function c52792430.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelBelow(c:GetLevel()) and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
-- 过滤出卡组中符合「捕食植物」属性且不是此卡本身的怪兽。
function c52792430.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and not c:IsCode(52792430) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标，检查是否有满足条件的怪兽可特殊召唤。
function c52792430.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「捕食植物」怪兽。
		and Duel.IsExistingMatchingCard(c52792430.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张「捕食植物」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组中选择一只符合条件的「捕食植物」怪兽并特殊召唤。
function c52792430.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位可以特殊召唤怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只符合条件的「捕食植物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c52792430.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
