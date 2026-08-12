--リグレット・リボーン
-- 效果：
-- 自己场上存在的怪兽被战斗破坏送去墓地时才能发动。那1只怪兽在自己场上表侧守备表示特殊召唤。这个效果特殊召唤的怪兽在自己的结束阶段时破坏。
function c79544790.initial_effect(c)
	-- 自己场上存在的怪兽被战斗破坏送去墓地时才能发动。那1只怪兽在自己场上表侧守备表示特殊召唤。这个效果特殊召唤的怪兽在自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c79544790.target)
	e1:SetOperation(c79544790.activate)
	c:RegisterEffect(e1)
end
-- 过滤在墓地、可以作为效果对象、原本控制者为自己、因战斗破坏、且可以表侧守备表示特殊召唤的怪兽
function c79544790.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeEffectTarget(e)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象选择与合法性检测
function c79544790.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c79544790.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c79544790.filter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c79544790.filter,1,1,nil,e,tp)
	-- 将选择的卡作为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置连锁信息，包含特殊召唤分类和目标卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的核心逻辑，特殊召唤目标怪兽并为其注册结束阶段破坏的效果
function c79544790.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个目标对象
	local tc=Duel.GetFirstTarget()
	-- 若目标卡片仍与效果相关，则将其在自己场上表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽在自己的结束阶段时破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCondition(c79544790.descon)
		e1:SetOperation(c79544790.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCountLimit(1)
		tc:RegisterEffect(e1,true)
	end
end
-- 检查当前是否为自己的回合，作为结束阶段破坏效果的触发条件
function c79544790.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 执行破坏该怪兽的操作
function c79544790.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
