--地縛戒隷 ジオグラシャ＝ラボラス
-- 效果：
-- 「地缚」融合怪兽＋「地缚」同调怪兽
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡和怪兽进行战斗的伤害步骤开始时发动。那只怪兽的攻击力·守备力变成0。
-- ②：对方怪兽被战斗·效果破坏的场合才能发动。对方场上的卡全部破坏。
-- ③：表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括融合召唤手续、特殊召唤限制、战斗时使对方怪兽攻防变0的诱发效果、对方怪兽被破坏时破坏对方全场卡的诱发效果，以及因对方离场时从卡组·额外卡组特召「地缚」怪兽的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「地缚」融合怪兽和「地缚」同调怪兽各1只。
	aux.AddFusionProcFun2(c,s.mfilter(TYPE_FUSION),s.mfilter(TYPE_SYNCHRO),true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	-- 设置特殊召唤限制为只能进行融合召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡和怪兽进行战斗的伤害步骤开始时发动。那只怪兽的攻击力·守备力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.zstg)
	e2:SetOperation(s.zsop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽被战斗·效果破坏的场合才能发动。对方场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡因对方从场上离开的场合才能发动。从卡组·额外卡组把1只「地缚」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.material_type=TYPE_FUSION+TYPE_SYNCHRO
-- 融合素材过滤函数，用于筛选属于「地缚」系列且属于指定怪兽类型（融合或同调）的怪兽。
function s.mfilter(typ)
	return  function(c)
				return c:IsFusionSetCard(0x21) and c:IsFusionType(typ)
			end
end
-- 效果①的发动条件检查：检查这张卡是否有正在进行战斗的对方怪兽。
function s.zstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetBattleTarget()~=nil end
end
-- 效果①的处理：将与这张卡进行战斗的对方怪兽的攻击力和守备力永久变成0。
function s.zsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if not (tc and tc:IsRelateToBattle()) then return end
	-- 那只怪兽的攻击力·守备力变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(0)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	tc:RegisterEffect(e2)
end
-- 过滤被战斗或效果破坏的对方怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动条件：检查是否有对方怪兽被战斗或效果破坏。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 效果②的靶向/发动条件检查：检查对方场上是否存在卡片，并设置破坏对方场上所有卡的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	-- 设置破坏操作信息，目标为对方场上的所有卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的处理：将对方场上的卡全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 因效果破坏获取到的对方场上的所有卡片。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果③的发动条件：检查表侧表示的这张卡是否因对方的操作从自己场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousControler(tp) and rp==1-tp
end
-- 过滤可以特殊召唤的「地缚」怪兽，并根据其所在位置（卡组或额外卡组）检查是否有可用的怪兽区域。
function s.filter(c,e,tp)
	return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若目标怪兽存在于额外卡组，则检查额外怪兽区域或相关区域是否有可用的空位。
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
			-- 若目标怪兽存在于卡组，则检查主怪兽区域是否有可用的空位。
			or c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- 效果③的靶向/发动条件检查：检查卡组或额外卡组是否存在可特殊召唤的「地缚」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的「地缚」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，数量为1，范围为卡组和额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果③的处理：从卡组或额外卡组选择1只「地缚」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「地缚」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
