--捕食植物スピノ・ディオネア
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害计算后才能发动。从卡组把「捕食植物 捕蝇草棘龙」以外的1只「捕食植物」怪兽特殊召唤。
function c52792430.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。
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
c52792430.mentioned_counter={
	[0x1041]=true,
}
-- 效果①的对象选择函数：检查对方场上是否存在可以放置捕食指示物的怪兽，并让玩家选择其中1只作为效果对象。
function c52792430.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	-- 检查对方场上是否存在至少1只可以放置1个捕食指示物的怪兽，作为效果能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 向玩家显示「请选择表侧表示的卡」的选卡提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只可以放置捕食指示物的怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 效果①的处理函数：给对象怪兽放置1个捕食指示物，若其等级在2星以上则注册一个将其等级变成1星的效果。
function c52792430.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
		-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c52792430.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级变更效果的适用条件：该怪兽上放置有捕食指示物时才持续适用。
function c52792430.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 效果②的发动条件：这张卡进行战斗的对手怪兽的等级在这张卡的等级以下，且是对方的怪兽并仍在战斗中。
function c52792430.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelBelow(c:GetLevel()) and bc:IsStatus(STATUS_OPPO_BATTLE) and bc:IsRelateToBattle()
end
-- 特殊召唤的过滤条件：是「捕食植物」怪兽、不是「捕食植物 捕蝇草棘龙」本身、且可以被特殊召唤。
function c52792430.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and not c:IsCode(52792430) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件检测：确认自己主要怪兽区有空位，且卡组存在满足条件的可以特殊召唤的「捕食植物」怪兽。
function c52792430.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在至少1只满足过滤条件的可以特殊召唤的「捕食植物」怪兽。
		and Duel.IsExistingMatchingCard(c52792430.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明将从卡组特殊召唤1只怪兽，供其他卡的效果发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数：确认有空位后，让玩家从卡组选择1只满足条件的「捕食植物」怪兽并将其特殊召唤。
function c52792430.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己主要怪兽区没有空格，则中断效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示「请选择要特殊召唤的卡」的选卡提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「捕食植物」怪兽。
	local g=Duel.SelectMatchingCard(tp,c52792430.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「捕食植物」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
