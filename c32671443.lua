--ドクターD
-- 效果：
-- ①：从自己墓地把1只「命运英雄」怪兽除外才能发动。从自己墓地选1只「命运英雄」怪兽加入手卡或特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上2只「命运英雄」怪兽为对象才能发动。作为对象的1只怪兽的攻击力变成和另1只怪兽的攻击力相同。
function c32671443.initial_effect(c)
	-- ①：从自己墓地把1只「命运英雄」怪兽除外才能发动。从自己墓地选1只「命运英雄」怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32671443,0))  --"加入手卡或特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c32671443.cost)
	e1:SetTarget(c32671443.target)
	e1:SetOperation(c32671443.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上2只「命运英雄」怪兽为对象才能发动。作为对象的1只怪兽的攻击力变成和另1只怪兽的攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32671443,1))  --"改变攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动COST为将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32671443.atktg)
	e2:SetOperation(c32671443.atkop)
	c:RegisterEffect(e2)
end
-- 定义作为①效果的COST除外的候选怪兽条件：是「命运英雄」怪兽、可从墓地除外，并且除外后墓地还存在至少1只满足①效果处理对象条件的「命运英雄」怪兽，确保COST后有效果可处理。
function c32671443.costfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 在COST筛选中追加检查：墓地存在至少1张除当前候选卡外、满足thfilter的「命运英雄」怪兽，用于保证发动后能选择目标。
		and Duel.IsExistingMatchingCard(c32671443.thfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 定义①效果处理对象的筛选条件：是「命运英雄」怪兽，并且能够加入手卡，或者能够特殊召唤到我方空余的主要怪兽区。
function c32671443.thfilter(c,e,tp)
	if not (c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取我方主要怪兽区的可用空位数，用于判断能否进行特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 实现①效果的发动COST：从自己墓地选择1只满足costfilter的「命运英雄」怪兽，以表侧表示除外。
function c32671443.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST合法性检查：自己墓地是否存在1只满足costfilter的「命运英雄」怪兽（costfilter内部已包含除外后仍能处理效果的条件）。
	if chk==0 then return Duel.IsExistingMatchingCard(c32671443.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“请选择要除外的卡”的选择提示，供玩家选择COST除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1只满足costfilter的「命运英雄」怪兽作为COST。
	local g=Duel.SelectMatchingCard(tp,c32671443.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选择的「命运英雄」怪兽以表侧表示除外，完成COST支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件判定：在COST已检查通过（e:IsCostChecked）或墓地存在满足thfilter的「命运英雄」怪兽时为可发动；不取对象，具体目标在效果处理时选择。
function c32671443.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- target中检查墓地存在至少1张满足thfilter的「命运英雄」怪兽，作为发动①效果的必要条件之一。
		or Duel.IsExistingMatchingCard(c32671443.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
-- ①效果处理：从自己墓地选择1只满足条件且不受王家长眠之谷影响的「命运英雄」怪兽，根据玩家选择或能否特殊召唤，将其加入手卡或特殊召唤。
function c32671443.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要操作的卡”的选择提示，供玩家选择要加入手卡或特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从墓地选择1张满足thfilter且不受王家长眠之谷影响的「命运英雄」怪兽（不取对象效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32671443.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取我方主要怪兽区的可用空位数，用于判断是否能特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand()
			-- 当目标卡能加入手卡，且（不能特殊召唤或没有空位或玩家选择“加入手卡”选项）时，选择加入手卡；否则选择特殊召唤。
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的「命运英雄」怪兽加入持有者手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 将选择的「命运英雄」怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果第一个对象候选的筛选条件：该卡是表侧表示的「命运英雄」怪兽，且场上存在另一只表侧表示、攻击力不同的「命运英雄」怪兽可作为第二个对象。
function c32671443.atkfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc008)
		-- 在atkfilter1中追加检查：存在至少1只除当前候选外、满足atkfilter2的表侧「命运英雄」怪兽，用于确保能选出2只攻击力不同的对象。
		and Duel.IsExistingTarget(c32671443.atkfilter2,tp,LOCATION_MZONE,0,1,c,c)
end
-- 定义②效果第二个对象候选的筛选条件：表侧表示、「命运英雄」怪兽，且攻击力与第一只候选怪兽的攻击力不同。
function c32671443.atkfilter2(c,tc)
	return c:IsFaceup() and c:IsSetCard(0xc008) and not c:IsAttack(tc:GetAttack())
end
-- 定义②效果可取对象的候选怪兽条件：表侧表示、「命运英雄」怪兽，并且能够成为当前效果的对象。
function c32671443.tgfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xc008) and c:IsCanBeEffectTarget(e)
end
-- 判断一组2张「命运英雄」怪兽的攻击力不同，作为选择对象子组的条件。
function c32671443.gcheck(g)
	return g:GetFirst():GetAttack()~=g:GetNext():GetAttack()
end
-- ②效果的目标处理：从自己场上的表侧表示「命运英雄」怪兽中选择2只攻击力不同的怪兽，设定为效果对象。
function c32671443.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时合法性检查：自己场上是否存在可选的表侧「命运英雄」怪兽组合（实质是存在2只攻击力不同的表侧「命运英雄」怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c32671443.atkfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 获取自己场上所有可以成为②效果对象的表侧「命运英雄」怪兽集合。
	local g=Duel.GetMatchingGroup(c32671443.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 弹出“请选择效果的对象”的选择提示，供玩家选择2只对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c32671443.gcheck,false,2,2)
	-- 将选择的2只「命运英雄」怪兽设为当前连锁的对象。
	Duel.SetTargetCard(tg)
end
-- ②效果处理：检查2只对象仍表侧且攻击力不同，从中选择1只，将其攻击力变成另1只的攻击力，并注册持续到怪兽离场等的攻击力变化效果。
function c32671443.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁相关的对象卡（即发动时选择的2只怪兽，若仍与效果关联）。
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	if g:GetFirst():GetAttack()==g:GetNext():GetAttack() then return end
	-- 弹出“请选择要改变攻击力的怪兽”的选择提示，供玩家选择攻击力被改变的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(32671443,2))  --"请选择要改变攻击力的怪兽"
	local tc2=g:Select(tp,1,1,nil):GetFirst()
	local tc1=(g-tc2):GetFirst()
	-- 作为对象的1只怪兽的攻击力变成和另1只怪兽的攻击力相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(tc1:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc2:RegisterEffect(e1)
end
