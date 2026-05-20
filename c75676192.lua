--F.A.ホームトランスポーター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡的攻击力上升这张卡的等级×300。
-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
-- ③：这张卡得到这张卡的等级的以下效果。
-- ●11星以上：这张卡不会被战斗·效果破坏。
-- ●13星以上：1回合1次，以自己墓地1只「方程式运动员」怪兽为对象才能发动。那只怪兽特殊召唤。
function c75676192.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡的攻击力上升这张卡的等级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c75676192.atkval)
	c:RegisterEffect(e1)
	-- ②：「方程式运动员」魔法·陷阱卡的效果发动的场合才能发动（伤害步骤也能发动）。这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75676192,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c75676192.lvcon)
	e3:SetOperation(c75676192.lvop)
	c:RegisterEffect(e3)
	-- ●11星以上：这张卡不会被战斗·效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(c75676192.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	-- ●13星以上：1回合1次，以自己墓地1只「方程式运动员」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(75676192,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c75676192.spcon)
	e6:SetTarget(c75676192.sptg)
	e6:SetOperation(c75676192.spop)
	c:RegisterEffect(e6)
end
-- 攻击力上升值的求值函数，返回当前等级×300的数值。
function c75676192.atkval(e,c)
	return c:GetLevel()*300
end
-- 判定发动效果的卡是否为「方程式运动员」魔法·陷阱卡。
function c75676192.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107)
end
-- 等级上升效果的处理：若自身在场上表侧表示存在，则使其等级上升1星。
function c75676192.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升1星。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_UPDATE_LEVEL)
		e4:SetValue(1)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e4)
	end
end
-- 破坏抗性效果的启用条件：自身等级在11星以上。
function c75676192.indcon(e)
	return e:GetHandler():IsLevelAbove(11)
end
-- 特殊召唤效果的发动条件：自身等级在13星以上。
function c75676192.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLevelAbove(13)
end
-- 过滤自己墓地可以特殊召唤的「方程式运动员」怪兽。
function c75676192.filter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向选择与发动合法性检测函数。
function c75676192.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c75676192.filter(chkc,e,tp) end
	-- 判定当前自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在至少1只满足条件的「方程式运动员」怪兽。
		and Duel.IsExistingTarget(c75676192.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的「方程式运动员」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c75676192.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，声明此效果包含特殊召唤1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行函数。
function c75676192.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
