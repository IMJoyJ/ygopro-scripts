--憑依共鳴
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「灵使」怪兽或「凭依装着」怪兽从自己的手卡·卡组·墓地表侧攻击表示或里侧守备表示特殊召唤。那之后，可以把作为对象的怪兽变成里侧守备表示。
-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 注册效果e1（①：取对象特殊召唤「灵使」或「凭依装着」怪兽并可将对象怪兽变里侧守备，魔陷发动·自由时点·取对象·1回合1次）和效果e2（②：墓地起动效果，取对象变更自己怪兽表示形式，cost为把这张卡除外，1回合1次）
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。属性和那只怪兽相同的1只「灵使」怪兽或「凭依装着」怪兽从自己的手卡·卡组·墓地表侧攻击表示或里侧守备表示特殊召唤。那之后，可以把作为对象的怪兽变成里侧守备表示。（这个卡名的①的效果1回合只能使用1次）
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
	-- ②：把墓地的这张卡除外，以自己场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。（这个卡名的②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设定②效果的cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 定义对象怪兽的过滤条件：表侧表示，且自己手卡·卡组·墓地存在与之属性相同、可特殊召唤的「灵使」或「凭依装着」怪兽
function s.filter1(c,e,tp)
	-- 判定该卡表侧表示且手卡·卡组·墓地至少存在1只属性与其相同的「灵使」或「凭依装着」可特殊召唤怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 定义特殊召唤候选的过滤条件：是怪兽、可以以表侧攻击或里侧守备表示特殊召唤、属于「灵使」(0x10c0)或「凭依装着」(0xbf)系列、属性与对象怪兽相同
function s.filter2(c,tc,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		and c:IsSetCard(0x10c0,0xbf)
		and c:IsAttribute(tc:GetAttribute())
end
-- ①效果的对象选择函数：校验连锁对象合法性，发动条件为自己主要怪兽区有空位且场上存在可作对象的表侧表示怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区至少有1个空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：双方场上存在1只满足条件的、可取为对象的表侧表示怪兽
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家发出「请选择效果的对象」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只满足条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将从自己手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果处理：确认怪兽区有空位、对象怪兽仍表侧且与连锁相关，选择并特殊召唤1只属性相同的「灵使」或「凭依装着」怪兽，之后可询问是否把对象怪兽变成里侧守备表示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己主要怪兽区没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToChain() then return end
	-- 向玩家发出「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组·墓地选择1只满足条件（且不受王家长眠之谷影响）的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tc,e,tp)
	-- 若选中了怪兽则以表侧攻击表示或里侧守备表示将其特殊召唤，并确认特殊召唤成功
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)>0
		and tc:IsFaceup() and tc:IsCanTurnSet()
		-- 对象怪兽仍表侧表示且可以变成里侧表示时，询问玩家是否将其变成里侧守备表示
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让对象怪兽变成里侧守备表示？"
		-- 中断效果处理，使后续的变里侧处理与特殊召唤不同时处理（避免同时处理判定）
		Duel.BreakEffect()
		-- 把作为对象的怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 定义②效果的对象过滤条件：可以改变表示形式的怪兽
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- ②效果的对象选择函数：校验对象为自己场上可改变表示形式的怪兽，发动条件为存在可取对象的该类怪兽，选择对象并设置改变表示形式的操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) and chkc:IsControler(tp) end
	-- 发动条件检查：自己场上存在1只可取对象的、可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出「请选择要改变表示形式的怪兽」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择自己场上1只可以改变表示形式的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁将改变1只对象怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若仍与连锁相关则变更其表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 变更对象怪兽的表示形式（表侧守备→表侧守备、里侧守备→表侧攻击，即攻击变守备、守备变攻击、里侧翻开为表侧攻击）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
