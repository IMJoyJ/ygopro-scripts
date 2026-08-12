--鬼動武者
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡和对方怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动，只在那次战斗阶段内那只对方怪兽的效果无效化。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化鬼动武者卡片效果，设置其为同调召唤限制卡并添加同调召唤手续
function c40509732.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(),1)
	-- ①：这张卡和对方怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c40509732.actcon)
	c:RegisterEffect(e1)
	-- ①：只在那次战斗阶段内那只对方怪兽的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.discon1)
	e2:SetOperation(s.disop1)
	c:RegisterEffect(e2)
	-- ①：只在那次战斗阶段内那只对方怪兽的效果无效化
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.distg)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e7)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40509732,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c40509732.spcon)
	e4:SetTarget(c40509732.sptg)
	e4:SetOperation(c40509732.spop)
	c:RegisterEffect(e4)
end
-- 判断是否满足①效果的发动条件，即该卡是否参与了战斗
function c40509732.actcon(e)
	local c=e:GetHandler()
	-- 该卡是否为攻击怪兽或被攻击怪兽且存在战斗目标
	return (Duel.GetAttacker()==c and c:GetBattleTarget()) or Duel.GetAttackTarget()==c
end
-- 判断是否满足①效果的发动条件，即该卡是否参与了战斗
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 该卡是否为攻击怪兽或被攻击怪兽且存在战斗目标
	return (c==Duel.GetAttacker() or c==Duel.GetAttackTarget()) and c:GetBattleTarget()
end
-- ①效果发动时，为战斗目标怪兽设置标记并刷新场上状态
function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 手动刷新场上受影响卡的无效状态
	Duel.AdjustInstantly(c)
end
-- 判断目标怪兽是否具有标记，用于判定是否被①效果无效
function s.distg(e,c)
	return c:GetFlagEffect(id)~=0
end
-- 判断②效果是否满足发动条件，即该卡是否因对方效果离场且处于表侧表示
function c40509732.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤满足条件的机械族怪兽，用于②效果的特殊召唤目标
function c40509732.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时，检查是否有满足条件的墓地机械族怪兽可特殊召唤
function c40509732.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c40509732.filter(chkc,e,tp) end
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的墓地机械族怪兽
		and Duel.IsExistingTarget(c40509732.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地机械族怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c40509732.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果发动时，将选中的墓地机械族怪兽特殊召唤
function c40509732.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特殊召唤方式送入场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
