--ブルル＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「@火灵天星」怪兽送去墓地。
-- ②：这张卡作为电子界族同调怪兽的同调素材送去墓地的场合，以「抖抖妖@火灵天星」以外的自己墓地1只作为那次同调召唤的素材的怪兽为对象才能发动。那只怪兽特殊召唤。
function c42429678.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「@火灵天星」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42429678,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,42429678)
	e1:SetTarget(c42429678.tgtg)
	e1:SetOperation(c42429678.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡作为电子界族同调怪兽的同调素材送去墓地的场合，以「抖抖妖@火灵天星」以外的自己墓地1只作为那次同调召唤的素材的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42429678,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,42429679)
	e3:SetCondition(c42429678.spcon)
	e3:SetTarget(c42429678.sptg)
	e3:SetOperation(c42429678.spop)
	c:RegisterEffect(e3)
end
-- 定义用于①效果的卡组送墓过滤函数：筛选持有「@火灵天星」字段、类型为怪兽且可以被送去墓地的卡。
function c42429678.tgfilter(c)
	return c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件与目标设定：在发动时确认卡组存在符合条件的「@火灵天星」怪兽，并设置将1张卡送去墓地的操作信息。
function c42429678.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己卡组中存在至少1张满足tgfilter条件的「@火灵天星」怪兽（若不存在则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(c42429678.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理将执行‘送去墓地’的操作信息：预定从自己卡组将1张卡送去墓地，用于卡组送墓相关效果的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从自己卡组选择1只满足条件的「@火灵天星」怪兽送去墓地。
function c42429678.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文本，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张满足tgfilter条件的「@火灵天星」怪兽。
	local g=Duel.SelectMatchingCard(tp,c42429678.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡作为同调素材被送去墓地，且由此同调召唤的怪兽为电子界族。
function c42429678.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsRace(RACE_CYBERSE)
end
-- 定义②效果选择对象的过滤函数：必须是墓地中属于自己控制、不是这张卡自身（抖抖妖@火灵天星）、能成为效果对象且能被特殊召唤的怪兽。
function c42429678.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and not c:IsCode(42429678) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的Target函数前半部分：获取同调召唤的素材组；若在处理对象选择时，确认候选卡属于素材且满足可特殊召唤条件；若为发动确认，则检查自己场上有空位且素材中存在可特殊召唤的怪兽。
function c42429678.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c42429678.spfilter(chkc,e,tp) end
	-- 发动时合法性检查：确认自己的主要怪兽区有空位可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c42429678.spfilter,1,nil,e,tp) end
	-- 显示选择提示文本，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c42429678.spfilter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(g)
	-- 设置本次效果处理将执行‘特殊召唤’的操作信息：预定将1张对象卡特殊召唤，用于特殊召唤相关效果的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：将取对象阶段选择的怪兽以表侧表示特殊召唤到自己场上（若该卡仍与效果关联）。
function c42429678.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个（也是唯一一个）效果对象，即被选为特殊召唤对象的素材怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区（不视为召唤条件/苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
