--真紅眼の飛竜
-- 效果：
-- 这张卡的效果发动的回合，自己不能通常召唤。
-- ①：自己结束阶段把墓地的这张卡除外，以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
function c67300516.initial_effect(c)
	-- 这张卡的效果发动的回合，自己不能通常召唤。①：自己结束阶段把墓地的这张卡除外，以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67300516,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c67300516.spcon)
	-- 将墓地的这张卡除外作为发动的Cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c67300516.sptg)
	e1:SetOperation(c67300516.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数（自己回合的结束阶段，且该回合自己没有进行过通常召唤）
function c67300516.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己回合，且自己在本回合内没有进行过通常召唤（包括放置）
	return Duel.GetTurnPlayer()==tp and Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 过滤条件：自己墓地中可以特殊召唤的「真红眼」怪兽
function c67300516.filter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标选择与合法性检测函数（Target）
function c67300516.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67300516.filter(chkc,e,tp) end
	-- 在发动时，判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，判定自己墓地是否存在除这张卡以外、满足条件的「真红眼」怪兽
		and Duel.IsExistingTarget(c67300516.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「真红眼」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c67300516.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理信息为：特殊召唤选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数（Operation）
function c67300516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
