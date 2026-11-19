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
-- ①效果的Target函数，检测发动时cost校验、怪兽区空格及能否作为陷阱怪兽特殊召唤，并设置特殊召唤操作信息
function c8522996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能将这张卡作为6星·恶魔族·暗属性·攻1000/守2400的效果陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,8522996,0,TYPES_EFFECT_TRAP_MONSTER,1000,2400,6,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息，声明将对这张卡进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的Operation函数，再次确认能否作为陷阱怪兽特招后，为这张卡追加效果怪兽与陷阱属性并特殊召唤到怪兽区
function c8522996.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时若玩家无法将该参数的陷阱怪兽特殊召唤则终止处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,8522996,0,TYPES_EFFECT_TRAP_MONSTER,1000,2400,6,RACE_FIEND,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果特殊召唤的标识(SUMMON_VALUE_SELF)将这张卡无视召唤条件以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- Condition函数，检查这张卡是否是通过自身效果(SUMMON_VALUE_SELF)特殊召唤到场上的
function c8522996.chcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果的Cost函数，从手卡丢弃1张可丢弃的卡作为发动代价
function c8522996.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测时，检查自己手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让自己在手卡选择1张可丢弃的卡作为发动代价丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的Target函数，确认这张卡在怪兽区域后让玩家宣言1个属性并保存到Label中
function c8522996.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_MZONE) end
	-- 向自己发送选择提示信息：“请选择要宣言的属性”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让自己在全属性中宣言1个属性
	local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(aat)
end
-- ②效果的Operation函数，为这张卡付与属性变为宣言属性以及同属性怪兽上级召唤时可作2只解放的效果
function c8522996.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabel()
	-- 这张卡当作宣言的属性使用，
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
-- 双倍解放的过滤函数，判断待上级召唤的怪兽c是否与这张卡当前属性相同
function c8522996.condition(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ec:GetAttribute()) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- ③效果的特殊召唤限制过滤函数，禁止玩家特殊召唤与这张卡当前属性不同的怪兽
function c8522996.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(e:GetHandler():GetAttribute())
end
