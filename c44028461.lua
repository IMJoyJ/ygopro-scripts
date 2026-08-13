--ブラック・バック
-- 效果：
-- 自己回合才能发动。选择自己墓地存在的1只攻击力2000以下的名字带有「黑羽」的怪兽特殊召唤。这张卡发动的回合，自己不能把怪兽通常召唤。
function c44028461.initial_effect(c)
	-- 自己回合才能发动。选择自己墓地存在的1只攻击力2000以下的名字带有「黑羽」的怪兽特殊召唤。这张卡发动的回合，自己不能把怪兽通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44028461.condition)
	e1:SetCost(c44028461.cost)
	e1:SetTarget(c44028461.target)
	e1:SetOperation(c44028461.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅当当前回合玩家为自己时才允许发动，以满足“自己回合才能发动”的限制。
function c44028461.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否等于效果发动者tp，是则条件成立，否则不能发动。
	return Duel.GetTurnPlayer()==tp
end
-- 定义发动代价/誓约处理：若本回合已进行过通常召唤则不能发动；发动时给自己场上施加“不能通常召唤”和“不能覆盖怪兽”的誓约效果，持续到结束阶段。
function c44028461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认本回合尚未进行过通常召唤（通常召唤次数为0）时才满足发动代价。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 选择自己墓地存在的1只攻击力2000以下的名字带有「黑羽」的怪兽特殊召唤。这张卡发动的回合，自己不能把怪兽通常召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能通常召唤”的誓约效果注册到场上，对己方玩家生效，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将“不能覆盖怪兽”的誓约效果（由同一个效果克隆并改变代码）注册到场上，对己方玩家生效，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 定义特殊召唤对象筛选条件：怪兽攻击力2000以下、属于「黑羽」字段、是怪兽且能够被特殊召唤（满足召唤条件和苏生限制）。
function c44028461.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择处理：若指定对象则校验其合法性；否则检查己方主要怪兽区是否有空格且墓地存在符合条件的「黑羽」怪兽。
function c44028461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44028461.filter(chkc,e,tp) end
	-- 检查己方主要怪兽区是否有至少1个可用区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足筛选条件的「黑羽」怪兽，且该怪兽能够成为效果对象。
		and Duel.IsExistingTarget(c44028461.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「黑羽」怪兽作为效果对象（取对象），并设置该卡为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c44028461.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果为特殊召唤，对象为选中的怪兽，数量为1，供其他效果检测参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理时的实际操作：取得对象怪兽，若对象仍与效果关联则将其特殊召唤。
function c44028461.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（通常为表侧攻击表示）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
