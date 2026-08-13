--ガスタの賢者 ウィンダール
-- 效果：
-- 这张卡战斗破坏怪兽送去墓地时，可以把自己墓地存在的1只3星以下的名字带有「薰风」的怪兽表侧守备表示特殊召唤。
function c27944249.initial_effect(c)
	-- 这张卡战斗破坏怪兽送去墓地时，可以把自己墓地存在的1只3星以下的名字带有「薰风」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27944249,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件，使用aux.bdgcon判定本卡与本次战斗有关，即本卡战斗破坏对方怪兽并将其送去墓地时才能发动。
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c27944249.target)
	e1:SetOperation(c27944249.operation)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤对象的过滤函数：选择自己墓地1只等级3以下、卡名带有「薰风」字段、且可以表侧守备表示特殊召唤的怪兽。
function c27944249.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动时的目标处理：先验证指定对象是否合法（位于自己墓地、属于自己控制且符合过滤条件），再检查发动条件（有可用的主要怪兽区且存在符合条件的墓地目标）。
function c27944249.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27944249.filter(chkc,e,tp) end
	-- 效果发动时检查自己的主要怪兽区是否有至少1个空位，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽，且该怪兽能够成为本效果的对象（取对象特殊召唤）。
		and Duel.IsExistingTarget(c27944249.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向当前玩家发送选择提示消息，提示内容为“请选择要特殊召唤的卡”，用于后续选卡界面的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的怪兽作为效果对象，并通过Duel.SelectTarget自动将其登记为当前连锁的特召对象。
	local g=Duel.SelectTarget(tp,c27944249.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息，声明本效果将进行特殊召唤，处理对象为已选择的怪兽g，数量为1，供其他卡效果（如星尘龙、王宫的铁壁等）进行联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理时的实际执行操作：取得效果发动时选择的目标，确认其仍与效果关联后，将其以表侧守备表示特殊召唤到自己场上。
function c27944249.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的目标怪兽（第一张对象卡），后续用于判断并执行特殊召唤。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上；此处不强制忽略召唤条件和苏生限制，因为目标已事先通过IsCanBeSpecialSummoned判定可以特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
