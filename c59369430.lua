--鋼鉄の大魔人ゴルゴイル
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：自己的机械族·幻想魔族怪兽进行战斗的伤害计算后，以自己的墓地·除外状态的1只怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡从场上除外的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己的机械族·幻想魔族怪兽进行战斗的伤害计算后，以自己的墓地·除外状态的1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上除外的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤不会被战斗破坏的怪兽，限定为自身以及与自身进行战斗的怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 判断效果②的发动条件，即自己的机械族或幻想魔族怪兽进行了战斗
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsRace(RACE_MACHINE+RACE_ILLUSION) or d and d:IsControler(tp) and d:IsRace(RACE_MACHINE+RACE_ILLUSION)
end
-- 过滤可以特殊召唤的、处于墓地或除外状态（表侧表示）的怪兽
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，包括检查怪兽区域空位、是否存在合法目标、进行目标选择并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 在发动时检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时检查自己的墓地或除外状态中是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果的操作为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的执行处理，将选中的对象怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的对象怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件，检查这张卡是否是从场上离开并被除外
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果③的发动准备，检查自己场上是否有空位以及自身是否可以特殊召唤，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明此效果的操作为特殊召唤这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的执行处理，将这张卡自身特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡自身以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
