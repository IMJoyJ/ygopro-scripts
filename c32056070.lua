--ユウ－Ai－
-- 效果：
-- ①：原本攻击力是2300的电子界族怪兽特殊召唤的场合，可以从那属性的以下效果选择1个发动。「友情-真“艾”-」的以下效果每1个属性在1回合只能选择1次。
-- ●地·水：选场上1只表侧表示怪兽，那个攻击力直到回合结束时变成一半。
-- ●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
-- ●炎·暗：在自己场上把1只「@火灵天星衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
function c32056070.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：原本攻击力是2300的电子界族怪兽特殊召唤的场合，可以从那属性的以下效果选择1个发动。「友情-真“艾”-」的以下效果每1个属性在1回合只能选择1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32056070,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c32056070.target)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定特殊召唤的怪兽是否原本攻击力为2300、电子界族、属性等于指定属性，且该属性在当前回合尚未被本卡效果使用过。
function c32056070.filter(c,att,used)
	return c:GetBaseAttack()==2300 and c:IsRace(RACE_CYBERSE) and c:IsAttribute(att) and c:GetAttribute()&used==0
end
-- 效果发动时的判定与处理：检查诱发条件，判断地水/风光/炎暗各分支是否可行，读取并更新本回合已用属性，让玩家选择要发动的属性，并为本卡效果设置对应的类别、处理函数和操作信息。
function c32056070.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 and not eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_ALL,0) then return false end
	-- 检查场上是否存在表侧表示且攻击力不为0的怪兽，作为地·水效果的可选对象。
	local b1=Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查场上是否存在可被无效化的表侧表示的卡，作为风·光效果的可选对象。
	local b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 检查自己主要怪兽区是否有空位，用于能否特殊召唤衍生物。
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己能否特殊召唤「@火灵天星衍生物」（电子界族·暗·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK)
	-- 读取本回合已使用过属性的标记值（未注册则为nil）。
	local used=Duel.GetFlagEffectLabel(tp,32056070)
	if used==nil then
		used=0
		-- 若尚未注册该回合标记，则注册一个结束阶段重置的标记，初始值为0，用于记录已选择过的属性。
		Duel.RegisterFlagEffect(tp,32056070,RESET_PHASE+PHASE_END,0,1,used)
	end
	local att=0
	if b1 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_EARTH,used) then att=att|ATTRIBUTE_EARTH end
	if b1 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_WATER,used) then att=att|ATTRIBUTE_WATER end
	if b2 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_WIND,used) then att=att|ATTRIBUTE_WIND end
	if b2 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_LIGHT,used) then att=att|ATTRIBUTE_LIGHT end
	if b3 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_FIRE,used) then att=att|ATTRIBUTE_FIRE end
	if b3 and eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_DARK,used) then att=att|ATTRIBUTE_DARK end
	if chk==0 then return att>0 end
	if att&(att-1)~=0 then
		-- 当可发动的属性不止一个时，向玩家提示需要选择要触发效果的属性。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32056070,1))  --"请选择要触发效果的属性"
		-- 让玩家从可选属性中宣言1个属性，作为本次实际发动的属性。
		att=Duel.AnnounceAttribute(tp,1,att)
	end
	used=used|att
	-- 将本次选择的属性加入已使用属性集合，并更新标记值，实现同一属性1回合只能选择1次。
	Duel.SetFlagEffectLabel(tp,32056070,used)
	if att&(ATTRIBUTE_EARTH+ATTRIBUTE_WATER)>0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetOperation(c32056070.attrop1)
	end
	if att&(ATTRIBUTE_WIND+ATTRIBUTE_LIGHT)>0 then
		e:SetCategory(0)
		e:SetOperation(c32056070.attrop2)
	end
	if att&(ATTRIBUTE_FIRE+ATTRIBUTE_DARK)>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c32056070.attrop3)
		-- 设置操作信息：本效果将特殊召唤1只怪兽，供后续连锁检测使用。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		-- 设置操作信息：本效果将产生1只衍生物。
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	end
end
-- 地·水效果的处理：从场上选择1只表侧表示怪兽，将其攻击力变成一半直到回合结束。
function c32056070.attrop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示且攻击力不为0的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	-- 显示所选怪兽的选中动画。
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	-- ●地·水：选场上1只表侧表示怪兽，那个攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(tc:GetAttack()/2))
	tc:RegisterEffect(e1)
end
-- 风·光效果的处理：选择场上1张表侧表示的卡，将其效果无效直到回合结束。
function c32056070.attrop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张可被无效的表侧表示的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g==0 then return end
	-- 显示所选卡的选中动画。
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	-- 使与所选卡相关联的连锁无效化，以完整实现“效果无效”。
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	-- ●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	-- ●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
end
-- 炎·暗效果的处理：先检查能否特殊召唤衍生物，再在自己场上把1只「@火灵天星衍生物」特殊召唤。
function c32056070.attrop3(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则无法特殊召唤衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若玩家无法特殊召唤衍生物，则效果处理终止。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then return end
	-- 创建1只「@火灵天星衍生物」（卡号32056071）的衍生物。
	local token=Duel.CreateToken(tp,32056071)
	-- 将衍生物以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
