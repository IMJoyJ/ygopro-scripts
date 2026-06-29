--憑依共鳴
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「灵使」怪兽或「凭依装着」怪兽从自己的手卡·卡组·墓地表侧攻击表示或里侧守备表示特殊召唤。那之后，可以把作为对象的怪兽变成里侧守备表示。
-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 注册魔法卡发动以场上怪兽为对象从多区域特召同属性灵使/凭依装着怪兽并可将该对象盖放、以及除外墓地自身变更场上怪兽表示形式的效果
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
	-- 将墓地的此卡除外作为效果②发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 场上表侧表示存在的、可作为效果对象且卡组/手卡/墓地存在同属性符合条件特召怪兽的过滤条件
function s.filter1(c,e,tp)
	-- 确认手卡、墓地或卡组中是否存在可特殊召唤的同属性灵使或凭依装着怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 手手、卡组或墓地中可特殊召唤 of 与对象怪兽属性相同且属于「灵使」或「凭依装着」字段的怪兽的过滤条件
function s.filter2(c,tc,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		and c:IsSetCard(0x10c0,0xbf)
		and c:IsAttribute(tc:GetAttribute())
end
-- 效果①的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 检查自己场上是否有空闲怪兽格以执行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以被选择为对象的怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家提示选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息为从手卡/卡组/墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 特殊召唤同属性灵使/凭依装着怪兽以及将对象怪兽盖放效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否有空闲怪兽格，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中关联的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToChain() then return end
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组或墓地中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc,e,tp)
	-- 将选择的怪兽以表侧攻击或里侧守备表示特殊召唤，若特召成功则处理后续的盖放
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFaceup() and tc:IsCanTurnSet()
		-- 询问玩家是否决定将场上的对象怪兽变为里侧守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让对象怪兽变成里侧守备表示？"
		-- 决定盖放时，切断连锁以执行后续动作
		Duel.BreakEffect()
		-- 将场上的对象怪兽转为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 场上存在的、可以改变表示形式的怪兽的过滤条件
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 效果②的发动准备与对象选择
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只怪兽作为改变形式的对象
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为变更表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 场上怪兽表示形式变更效果的执行
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的作为形式变更对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 执行怪兽表示形式在表侧守备与表侧攻击之间的切换
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
