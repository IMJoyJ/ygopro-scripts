--憑依共鳴
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「灵使」怪兽或「凭依装着」怪兽从自己的手卡·卡组·墓地表侧攻击表示或里侧守备表示特殊召唤。那之后，可以把作为对象的怪兽变成里侧守备表示。
-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 注册两个效果，①为发动效果，②为墓地发动的效果
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「灵使」怪兽或「凭依装着」怪兽从自己的手卡·卡组·墓地表侧攻击表示或里侧守备表示特殊召唤。那之后，可以把作为对象的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤条件：对象怪兽为表侧表示且自己手卡·墓地·卡组存在满足条件的「灵使」或「凭依装着」怪兽
function s.filter1(c,e,tp)
	-- 对象怪兽为表侧表示且自己手卡·墓地·卡组存在满足条件的「灵使」或「凭依装着」怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 过滤条件：满足怪兽卡、可特殊召唤、为「灵使」或「凭依装着」卡、属性与对象怪兽相同
function s.filter2(c,tc,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		and c:IsSetCard(0x10c0,0xbf)
		and c:IsAttribute(tc:GetAttribute())
end
-- 处理①效果的target函数，判断是否能选择对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的对象怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的对象怪兽
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤1张手卡·墓地·卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 处理①效果的activate函数，执行特殊召唤和表示形式变更
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToChain() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「灵使」或「凭依装着」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc,e,tp)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		and tc:IsFaceup() and tc:IsCanTurnSet()
		-- 询问是否将对象怪兽变为里侧守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让对象怪兽变成里侧守备表示？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将对象怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：可改变表示形式
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 处理②效果的target函数，判断是否能选择对象
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc:IsControler(tp) end
	-- 判断场上是否存在满足条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上满足条件的对象怪兽
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将要改变对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理②效果的operation函数，执行表示形式变更
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象怪兽变为表侧守备表示或表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
