--No.92 偽骸神龍 Heart－eartH Dragon
-- 效果：
-- 9星怪兽×3
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ②：对方结束阶段把这张卡1个超量素材取除才能发动。把这个回合召唤·特殊召唤·盖放的对方场上的卡全部除外。
-- ③：持有超量素材的这张卡被破坏送去墓地的场合才能发动。这张卡特殊召唤。
-- ④：这张卡用自身的效果特殊召唤的场合发动。这张卡的攻击力上升除外中的卡数量×1000。
function c97403510.initial_effect(c)
	-- 设置XYZ召唤手续：9星怪兽×3。
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- 这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对方结束阶段把这张卡1个超量素材取除才能发动。把这个回合召唤·特殊召唤·盖放的对方场上的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97403510,0))  --"卡片除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c97403510.rmcon)
	e3:SetCost(c97403510.rmcost)
	e3:SetTarget(c97403510.rmtg)
	e3:SetOperation(c97403510.rmop)
	c:RegisterEffect(e3)
	-- 持有超量素材的这张卡被破坏送去墓地的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97403510,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c97403510.spcon)
	e4:SetTarget(c97403510.sptg)
	e4:SetOperation(c97403510.spop)
	c:RegisterEffect(e4)
	-- 这张卡用自身的效果特殊召唤的场合发动。这张卡的攻击力上升除外中的卡数量×1000。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(97403510,2))  --"攻击上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c97403510.atkcon)
	e5:SetOperation(c97403510.atkop)
	c:RegisterEffect(e5)
	if not c97403510.global_check then
		c97403510.global_check=true
		-- 把这个回合召唤·特殊召唤·盖放的对方场上的卡全部除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c97403510.checkop)
		-- 注册全局效果，用于记录本回合盖放的卡片。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 设置该怪兽的「No.」编号为92。
aux.xyz_number[97403510]=92
-- 全局记录盖放卡片的操作，给本回合盖放的卡片添加标记。
function c97403510.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(97403510,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 除外效果的发动条件：对方的回合。
function c97403510.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 除外效果的消耗：把这张卡1个超量素材取除。
function c97403510.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：在本回合召唤、特殊召唤（在怪兽区且回合ID相同）或盖放（有标记且回合ID相同）的对方场上的卡，且可以被除外。
function c97403510.filter(c,turn)
	return (c:IsLocation(LOCATION_MZONE) or c:GetFlagEffect(97403510)~=0) and c:GetTurnID()==turn and c:IsAbleToRemove()
end
-- 除外效果的发动准备：检查是否存在符合条件的卡，并设置除外操作信息。
function c97403510.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张本回合召唤·特殊召唤·盖放且可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c97403510.filter,tp,0,LOCATION_ONFIELD,1,nil,Duel.GetTurnCount()) end
	-- 获取对方场上所有满足条件的本回合召唤·特殊召唤·盖放的卡片组。
	local g=Duel.GetMatchingGroup(c97403510.filter,tp,0,LOCATION_ONFIELD,nil,Duel.GetTurnCount())
	-- 设置连锁处理的操作信息，表示将这些卡片除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 除外效果的实际处理：将满足条件的卡全部除外。
function c97403510.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上所有满足条件的本回合召唤·特殊召唤·盖放的卡片组。
	local g=Duel.GetMatchingGroup(c97403510.filter,tp,0,LOCATION_ONFIELD,nil,Duel.GetTurnCount())
	if g:GetCount()>0 then
		-- 将目标卡片组以表侧表示除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件：这张卡因破坏送去墓地，且在场上时持有超量素材。
function c97403510.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetPreviousOverlayCountOnField()>0
end
-- 特殊召唤效果的发动准备：检查自身是否仍在墓地、怪兽区域是否有空位，以及自身是否可以特殊召唤，并设置特殊召唤操作信息。
function c97403510.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡是否与效果相关联，且自己场上是否有可用的怪兽区域空格。
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理：将这张卡特殊召唤。
function c97403510.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以自身效果（带有特定召唤标记）在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击力上升效果的发动条件：这张卡是通过自身效果特殊召唤成功的。
function c97403510.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力上升效果的实际处理：计算除外中的卡片数量，使这张卡的攻击力上升该数量×1000。
function c97403510.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算双方除外区卡片总数，并乘以1000作为攻击力上升值。
	local atk=Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)*1000
	if atk>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升除外中的卡数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
