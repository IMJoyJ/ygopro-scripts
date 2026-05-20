--暗黒界の書物
-- 效果：
-- 自己的结束阶段时手卡数量限制把手卡丢弃去墓地的场合，若那之中包含有怪兽卡可以只把1只在自己场上特殊召唤。
function c61623148.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的结束阶段时手卡数量限制把手卡丢弃去墓地的场合，若那之中包含有怪兽卡可以只把1只在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61623148,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c61623148.spcon)
	e2:SetTarget(c61623148.sptg)
	e2:SetOperation(c61623148.spop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：检查是否在自己的结束阶段因手卡数量限制而将卡丢弃去墓地
function c61623148.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是自己，且丢弃原因包含规则调整（手卡数量限制丢弃）
	return Duel.GetTurnPlayer()==tp and bit.band(r,REASON_ADJUST)~=0
end
-- 过滤条件：筛选可以特殊召唤的怪兽
function c61623148.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：验证怪兽区空位并选择被丢弃的怪兽作为对象
function c61623148.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c61623148.filter(chkc,e,tp) end
	-- 在发动检测时，确认自己场上有怪兽区域空位，且被丢弃的卡中存在可以特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c61623148.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c61623148.filter,1,1,nil,e,tp)
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理信息，包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的对象怪兽特殊召唤到自己场上
function c61623148.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
