--魅惑の合わせ鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「鹰身女郎」或者「鹰身女郎三姐妹」被战斗破坏时才能发动。原本卡名和那只怪兽不同的1只「鹰身」怪兽从卡组特殊召唤。
-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合，以自己墓地1只「鹰身」怪兽为对象发动。那只怪兽特殊召唤。
function c92881099.initial_effect(c)
	-- 记录这张卡的效果文本上记载了「鹰身女郎」(76812113)和「鹰身女郎三姐妹」(12206212)的卡名。
	aux.AddCodeList(c,76812113,12206212)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己的「鹰身女郎」或者「鹰身女郎三姐妹」被战斗破坏时才能发动。原本卡名和那只怪兽不同的1只「鹰身」怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92881099,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,92881099)
	e2:SetCondition(c92881099.spcon)
	e2:SetTarget(c92881099.sptg)
	e2:SetOperation(c92881099.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合，以自己墓地1只「鹰身」怪兽为对象发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,92881100)
	e3:SetCondition(c92881099.spcon2)
	e3:SetTarget(c92881099.sptg2)
	e3:SetOperation(c92881099.spop2)
	c:RegisterEffect(e3)
end
-- 定义①效果战破触发过滤函数：检查被破坏的卡片破坏前在场上卡名为「鹰身女郎」或「鹰身女郎三姐妹」，且此前位于自己怪兽区由自己控制。
function c92881099.cfilter(c,tp)
	return (c:GetPreviousCodeOnField()==76812113 or c:GetPreviousCodeOnField()==12206212)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ①效果发动条件检查函数：确认本次战斗破坏送墓的事件卡片组中存在至少1只符合条件的己方「鹰身女郎」或「鹰身女郎三姐妹」。
function c92881099.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(c92881099.cfilter,nil,tp)>0
end
-- 定义①效果卡组特召过滤函数：检查卡组怪兽的原本卡名与被战破怪兽卡片组g中所有怪兽均不同，且属于「鹰身」(0x64)字段并能正规特殊召唤。
function c92881099.spfilter(c,e,tp,g)
	local diff=true
	-- 遍历被战斗破坏的符合条件己方怪兽卡片组g，逐一比对其原本卡名。
	for tc in aux.Next(g) do
		if c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) then
			diff=false
			break
		end
	end
	return diff and c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动检查函数：筛选出被战破的己方目标怪兽组g0，确认自己怪兽区有空位且卡组存在原本卡名不同的可特召「鹰身」怪兽。
function c92881099.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g0=eg:Filter(c92881099.cfilter,nil,tp)
	-- 在检查能否发动时，确认自己主要怪兽区至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只原本卡名与被战破怪兽不同的可特殊召唤「鹰身」怪兽。
		and Duel.IsExistingMatchingCard(c92881099.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,g0) end
	-- 向引擎登记本次连锁预计从自己卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理函数：确认自己怪兽区有空位且这张永续魔法仍在场与效果关联后，从卡组选1只原本卡名不同的「鹰身」怪兽特殊召唤。
function c92881099.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否没有可用空位，或这张永续魔法卡是否已离场失去与效果的联系，若是则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 向玩家发送选择要从卡组特殊召唤怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g0=eg:Filter(c92881099.cfilter,nil,tp)
	-- 让玩家从自己卡组选择1只满足原本卡名不同条件的「鹰身」怪兽。
	local g=Duel.SelectMatchingCard(tp,c92881099.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g0)
	if g:GetCount()>0 then
		-- 将选中的「鹰身」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果墓地特召过滤函数：检查墓地怪兽是否属于「鹰身」(0x64)字段且可以正规特殊召唤。
function c92881099.spfilter2(c,e,tp)
	return c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件函数：检查被破坏的这张卡破坏前位于自己场上，且破坏原因效果由对方发动或由自己的「鹰身」卡发动。
function c92881099.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (rp==1-tp or (rp==tp and re:GetHandler():IsSetCard(0x64))) and c:IsPreviousControler(tp)
end
-- ②效果必发对象选择函数：无条件进入对象选择阶段（因必发效果），选择自己墓地1只「鹰身」怪兽作为对象并登记特召操作信息。
function c92881099.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92881099.spfilter2(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家发送选择要特殊召唤的墓地「鹰身」怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「鹰身」怪兽作为当前连锁的发动对象。
	local g=Duel.SelectTarget(tp,c92881099.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向引擎登记本次连锁确定将对象怪兽特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理函数：若对象怪兽存在且仍与效果保持联系，则将其以表侧表示特殊召唤到自己场上。
function c92881099.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
