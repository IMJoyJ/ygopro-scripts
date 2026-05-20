--始源の帝王
-- 效果：
-- ①：这张卡发动后变成效果怪兽（恶魔族·暗·6星·攻1000/守2400）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果让这张卡特殊召唤的场合，丢弃1张手卡，宣言1个属性才能发动。这张卡当作宣言的属性使用，和这张卡相同属性的怪兽上级召唤的场合，可以作为2只的数量解放。
-- ③：只要这张卡的效果特殊召唤的这张卡存在，自己不是和这张卡相同属性的怪兽不能特殊召唤。
function c8522996.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（恶魔族·暗·6星·攻1000/守2400）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c8522996.target)
	e1:SetOperation(c8522996.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡特殊召唤的场合，丢弃1张手卡，宣言1个属性才能发动。这张卡当作宣言的属性使用，和这张卡相同属性的怪兽上级召唤的场合，可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8522996,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c8522996.chcon)
	e2:SetCost(c8522996.chcost)
	e2:SetTarget(c8522996.chtg)
	e2:SetOperation(c8522996.chop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡的效果特殊召唤的这张卡存在，自己不是和这张卡相同属性的怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c8522996.chcon)
	e3:SetTarget(c8522996.splimit)
	c:RegisterEffect(e3)
end
-- 检查发动这张卡（特殊召唤为怪兽）的条件是否满足（怪兽区域有空位，且玩家可以特殊召唤该陷阱怪兽）
function c8522996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该特定属性、种族、攻守和等级的陷阱怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8522996,0,TYPES_EFFECT_TRAP_MONSTER,1000,2400,6,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动时的效果处理：将这张卡作为效果怪兽和陷阱卡在怪兽区域特殊召唤
function c8522996.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次检查是否仍能特殊召唤该陷阱怪兽，若不能则直接结束处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,8522996,0,TYPES_EFFECT_TRAP_MONSTER,1000,2400,6,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤到怪兽区域
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 检查这张卡是否是通过自身效果特殊召唤的
function c8522996.chcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 丢弃1张手卡作为发动效果的代价
function c8522996.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的目标处理：让玩家宣言1个属性，并将宣言的属性保存在效果标签中
function c8522996.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性
	local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(aat)
end
-- 效果处理：使这张卡变为宣言的属性，并赋予其在作为相同属性怪兽上级召唤的解放时可作为2只数量解放的效果
function c8522996.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabel()
	-- 这张卡当作宣言的属性使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(att)
	e1:SetReset(RESET_EVENT+RESET_DISABLE+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 和这张卡相同属性的怪兽上级召唤的场合，可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c8522996.condition)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 检查进行上级召唤的怪兽属性是否与这张卡当前的属性相同
function c8522996.condition(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute())
end
-- 限制自己不能特殊召唤与这张卡属性不同的怪兽
function c8522996.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(e:GetHandler():GetAttribute())
end
