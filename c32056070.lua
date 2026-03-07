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
	-- 效果原文内容：①：原本攻击力是2300的电子界族怪兽特殊召唤的场合，可以从那属性的以下效果选择1个发动。「友情-真“艾”-」的以下效果每1个属性在1回合只能选择1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32056070,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c32056070.target)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤满足条件的怪兽，即攻击力为2300、种族为电子界、属性为指定属性且未被使用过的怪兽
function c32056070.filter(c,att,used)
	return c:GetBaseAttack()==2300 and c:IsRace(RACE_CYBERSE) and c:IsAttribute(att) and c:GetAttribute()&used==0
end
-- 规则层面作用：检查是否有满足条件的怪兽特殊召唤成功，判断是否可以发动效果，同时检查三种效果是否可用
function c32056070.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 and not eg:IsExists(c32056070.filter,1,nil,ATTRIBUTE_ALL,0) then return false end
	-- 规则层面作用：检查场上是否存在攻击力不为0的表侧表示怪兽
	local b1=Duel.IsExistingMatchingCard(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 规则层面作用：检查场上是否存在可作为无效化目标的卡
	local b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 规则层面作用：检查玩家在主要怪兽区是否有空位
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家是否可以特殊召唤token怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK)
	-- 规则层面作用：获取玩家已使用的属性标记
	local used=Duel.GetFlagEffectLabel(tp,32056070)
	if used==nil then
		used=0
		-- 规则层面作用：注册一个标识效果，用于记录已使用的属性
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
		-- 规则层面作用：提示玩家选择要触发效果的属性
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32056070,1))  --"请选择要触发效果的属性"
		-- 规则层面作用：让玩家宣言一个属性
		att=Duel.AnnounceAttribute(tp,1,att)
	end
	used=used|att
	-- 规则层面作用：设置已使用的属性标记
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
		-- 规则层面作用：设置连锁操作信息，指定将要特殊召唤token怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		-- 规则层面作用：设置连锁操作信息，指定将要特殊召唤token怪兽
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	end
end
-- 效果原文内容：●地·水：选场上1只表侧表示怪兽，那个攻击力直到回合结束时变成一半。
function c32056070.attrop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面作用：选择场上1只表侧表示的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	-- 规则层面作用：显示所选怪兽被选为对象的动画效果
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	-- 效果原文内容：●地·水：选场上1只表侧表示怪兽，那个攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(math.ceil(tc:GetAttack()/2))
	tc:RegisterEffect(e1)
end
-- 效果原文内容：●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
function c32056070.attrop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 规则层面作用：选择场上1张可作为无效化目标的卡
	local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g==0 then return end
	-- 规则层面作用：显示所选卡被选为对象的动画效果
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	-- 规则层面作用：使与所选卡相关的连锁无效化
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	-- 效果原文内容：●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	-- 效果原文内容：●风·光：选场上1张表侧表示的卡，那个效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e2)
end
-- 效果原文内容：●炎·暗：在自己场上把1只「@火灵天星衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
function c32056070.attrop3(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家在主要怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 规则层面作用：检查玩家是否可以特殊召唤token怪兽
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,11738490,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then return end
	-- 规则层面作用：创建一个token怪兽
	local token=Duel.CreateToken(tp,32056071)
	-- 规则层面作用：将token怪兽特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
