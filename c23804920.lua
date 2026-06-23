--聖神獣セルケト
-- 效果：
-- 「塞勒凯特」怪兽＋攻击力2500以下的怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡和对方怪兽进行战斗的伤害步骤开始时，以对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力上升除外的怪兽的原本攻击力一半数值。
-- ②：只要10星以上的怪兽除外中，这张卡在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制，设置融合召唤条件为「塞勒凯特」怪兽和攻击力2500以下的怪兽，创建特殊召唤时和战斗开始时的两个诱发效果，以及额外攻击效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤条件为必须使用一张「塞勒凯特」融合素材和一张攻击力2500以下的怪兽作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c7),aux.FilterBoolFunction(Card.IsAttackBelow,2500),true)
	-- ①：这张卡特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ②：只要10星以上的怪兽除外中，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.eacon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 定义用于筛选目标怪兽的过滤函数，要求目标为怪兽卡、正面表示且能除外。
function s.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToRemove()
end
-- 判断是否满足效果发动条件，即当前卡正在与对方怪兽战斗。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsControler(1-tp)
end
-- 设置效果的目标选择处理，允许选择对方场上或墓地的1只怪兽作为除外对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
	-- 检查是否满足发动条件，即对方场上或墓地存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,c) end
	-- 向玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上选择满足条件的目标怪兽，若无法满足则使用普通选择方式。
	local g=aux.SelectTargetFromFieldFirst(tp,s.atkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,c)
	-- 设置连锁操作信息，指定本次效果将除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽除外并提升自身攻击力。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足效果发动条件，包括不受王家长眠之谷影响、为怪兽卡、且在连锁中存在。
	if tc and aux.NecroValleyFilter()(tc) and tc:IsType(TYPE_MONSTER)
		-- 将目标怪兽除外，若成功则继续处理效果。
		and tc:IsRelateToChain() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN))
		and c:IsRelateToChain() and c:IsFaceup() then
		local upval=tc:GetBaseAttack()
		-- 将自身攻击力提升为除外怪兽原本攻击力的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(upval/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足额外攻击效果的发动条件，即对方墓地存在至少1只10星以上的怪兽。
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方墓地是否存在至少1只10星以上的正面表示怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsLevelAbove),0,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,10)
end
