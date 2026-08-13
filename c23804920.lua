--聖神獣セルケト
-- 效果：
-- 「塞勒凯特」怪兽＋攻击力2500以下的怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合或者这张卡和对方怪兽进行战斗的伤害步骤开始时，以对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力上升除外的怪兽的原本攻击力一半数值。
-- ②：只要10星以上的怪兽除外中，这张卡在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化该卡效果：设定融合召唤素材（塞勒凯特怪兽＋攻击力2500以下怪兽），注册①特殊召唤成功时/伤害步骤开始时除外对方怪兽并加攻的诱发效果（1回合1次），注册②除外区有10星以上怪兽时追加攻击的永续效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材：1只「塞勒凯特」怪兽＋1只攻击力2500以下的怪兽。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1c7),aux.FilterBoolFunction(Card.IsAttackBelow,2500),true)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合或者这张卡和对方怪兽进行战斗的伤害步骤开始时，以对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力上升除外的怪兽的原本攻击力一半数值。
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
	-- ①：这张卡特殊召唤的场合或者这张卡和对方怪兽进行战斗的伤害步骤开始时，以对方的场上（表侧表示）·墓地1只怪兽为对象才能发动。那只怪兽除外，这张卡的攻击力上升除外的怪兽的原本攻击力一半数值。
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
-- 定义目标筛选条件：怪兽、处于表侧表示（或墓地区域）、且能够被除外。
function s.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToRemove()
end
-- 该效果的发动条件：这张卡与对方怪兽进行战斗（伤害步骤开始时，战斗对象为对方怪兽）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsControler(1-tp)
end
-- ①效果的目标选择函数：从对方场上表侧表示或墓地的怪兽中选择1只为对象；发动时校验可选目标存在；提示选择要除外的卡；调用辅助函数优先从场上选择，不足则从墓地选择，并将选择对象登记为连锁对象，设置除外操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
	-- 发动时的合法性检查：确认对方场上表侧表示或墓地存在至少1只满足除外条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,c) end
	-- 显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 使用辅助选择函数，让玩家优先从对方场上，其次从墓地选择1只符合条件的怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=aux.SelectTargetFromFieldFirst(tp,s.atkfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,c)
	-- 设置操作信息：声明将除外目标卡，供连锁相关的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：表侧除外目标怪兽；若目标与本连锁相关且除外成功（或目标为衍生物而消失），且本卡仍与连锁相关并表侧表示，则给本卡附加攻击力上升效果，上升值为目标原本攻击力的一半。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标仍然存在：未受王家长眠之谷影响而不能除外，且为怪兽。
	if tc and aux.NecroValleyFilter()(tc) and tc:IsType(TYPE_MONSTER)
		-- 确认目标与本连锁相关后，将其表侧除外；如果除外成功则继续执行加攻。
		and tc:IsRelateToChain() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN))
		and c:IsRelateToChain() and c:IsFaceup() then
		local upval=tc:GetBaseAttack()
		-- 这张卡的攻击力上升除外的怪兽的原本攻击力一半数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(upval/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的适用条件：只要除外区有10星以上的表侧表示怪兽存在，就满足。
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除外区是否存在1张以上表侧表示且等级10以上的怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsLevelAbove),0,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,10)
end
