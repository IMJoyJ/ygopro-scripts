--魅惑の合わせ鏡
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「鹰身女郎」或者「鹰身女郎三姐妹」被战斗破坏时才能发动。原本卡名和那只怪兽不同的1只「鹰身」怪兽从卡组特殊召唤。
-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合，以自己墓地1只「鹰身」怪兽为对象发动。那只怪兽特殊召唤。
function c92881099.initial_effect(c)
	-- 将「鹰身女郎三姐妹」的卡片密码加入卡片记述列表，以便其他卡片检索或关联。
	aux.AddCodeList(c,12206212)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「鹰身女郎」或者「鹰身女郎三姐妹」被战斗破坏时才能发动。原本卡名和那只怪兽不同的1只「鹰身」怪兽从卡组特殊召唤。
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
	-- ②：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏的场合，以自己墓地1只「鹰身」怪兽为对象发动。那只怪兽特殊召唤。
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
-- 过滤条件：原本卡名为「鹰身女郎」或「鹰身女郎三姐妹」且在自己场上被破坏的怪兽。
function c92881099.cfilter(c,tp)
	return (c:GetPreviousCodeOnField()==76812113 or c:GetPreviousCodeOnField()==12206212)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果①的发动条件：检查是否有符合条件的怪兽被战斗破坏。
function c92881099.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(c92881099.cfilter,nil,tp)>0
end
-- 过滤条件：卡组中原本卡名与被破坏怪兽不同且可以特殊召唤的「鹰身」怪兽。
function c92881099.spfilter(c,e,tp,g)
	local diff=true
	-- 遍历被战斗破坏的怪兽组。
	for tc in aux.Next(g) do
		if c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) then
			diff=false
			break
		end
	end
	return diff and c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位并确认卡组中是否存在可特殊召唤的、原本卡名不同的「鹰身」怪兽。
function c92881099.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g0=eg:Filter(c92881099.cfilter,nil,tp)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「鹰身」怪兽。
		and Duel.IsExistingMatchingCard(c92881099.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,g0) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1只原本卡名不同的「鹰身」怪兽特殊召唤。
function c92881099.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用怪兽区域，或者此卡已不在魔陷区，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g0=eg:Filter(c92881099.cfilter,nil,tp)
	-- 从卡组中选择1只原本卡名与被破坏怪兽不同的「鹰身」怪兽。
	local g=Duel.SelectMatchingCard(tp,c92881099.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,g0)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：墓地中可以特殊召唤的「鹰身」怪兽。
function c92881099.spfilter2(c,e,tp)
	return c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：场上的这张卡被对方的效果或者自己的「鹰身」卡的效果破坏。
function c92881099.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (rp==1-tp or (rp==tp and re:GetHandler():IsSetCard(0x64))) and c:IsPreviousControler(tp)
end
-- 效果②的发动准备：选择自己墓地1只「鹰身」怪兽为对象。
function c92881099.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92881099.spfilter2(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「鹰身」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c92881099.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将作为对象的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽特殊召唤。
function c92881099.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
