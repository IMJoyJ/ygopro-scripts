--ダメージ・ゲート
-- 效果：
-- 自己受到战斗伤害时才能发动。把持有那个时候受到的伤害数值以下的攻击力的1只怪兽从自己墓地往场上特殊召唤。
function c87106146.initial_effect(c)
	-- 自己受到战斗伤害时才能发动。把持有那个时候受到的伤害数值以下的攻击力的1只怪兽从自己墓地往场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c87106146.condition)
	e1:SetTarget(c87106146.target)
	e1:SetOperation(c87106146.activate)
	c:RegisterEffect(e1)
end
-- 判定受到战斗伤害的玩家是否为自己
function c87106146.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤墓地中攻击力在受到的伤害数值以下、且可以特殊召唤的怪兽
function c87106146.filter(c,e,tp,dam)
	return c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与合法性检测
function c87106146.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87106146.filter(chkc,e,tp,ev) end
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己墓地是否存在至少1只满足条件的怪兽可以作为效果对象
		and Duel.IsExistingTarget(c87106146.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ev) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87106146.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ev)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，将选中的墓地怪兽特殊召唤
function c87106146.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
