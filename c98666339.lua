--リバースディメンション
-- 效果：
-- 原本的持有者是自己的怪兽被对方的效果从游戏中除外时才能发动。那1只怪兽在自己场上特殊召唤。
function c98666339.initial_effect(c)
	-- 原本的持有者是自己的怪兽被对方的效果从游戏中除外时才能发动。那1只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c98666339.target)
	e1:SetOperation(c98666339.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足原本持有者是自己、被对方效果除外、呈表侧表示且可以特殊召唤的怪兽
function c98666339.filter(c,e,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:GetReasonPlayer()==1-tp
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与条件检查，确认除外区有符合条件的怪兽且自身场上有空位
function c98666339.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and eg:IsContains(chkc) and c98666339.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c98666339.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c98666339.filter,1,1,nil,e,tp)
	-- 将选择的怪兽设置为效果的对象
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息，表明该效果包含特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行，将成为对象的怪兽特殊召唤到自己场上
function c98666339.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时成为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
