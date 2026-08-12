--デスピアの凶劇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。场上的全部怪兽的攻击力直到对方回合结束时上升自身的等级×100。
-- ②：手卡·场上的这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合，以「死狱乡的凶剧」以外的自己墓地·除外状态的1只「死狱乡」怪兽或者8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。
function c81555617.initial_effect(c)
	-- ①：自己主要阶段才能发动。场上的全部怪兽的攻击力直到对方回合结束时上升自身的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81555617,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,81555617)
	e1:SetTarget(c81555617.atktg)
	e1:SetOperation(c81555617.atkop)
	c:RegisterEffect(e1)
	-- ②：手卡·场上的这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合，以「死狱乡的凶剧」以外的自己墓地·除外状态的1只「死狱乡」怪兽或者8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81555617,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,81555618)
	e2:SetCondition(c81555617.spcon)
	e2:SetTarget(c81555617.sptg)
	e2:SetOperation(c81555617.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且等级在0以上的怪兽
function c81555617.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- ①效果的发动准备：检查场上是否存在满足攻击力上升条件的怪兽
function c81555617.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在至少1只表侧表示且等级在0以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81555617.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- ①效果的执行：使双方场上所有符合条件的怪兽攻击力上升各自等级×100，直到对方回合结束时
function c81555617.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示且等级在0以上的怪兽
	local g=Duel.GetMatchingGroup(c81555617.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 遍历所有满足条件的怪兽进行处理
	for tc in aux.Next(g) do
		local lv=tc:GetLevel()
		-- 攻击力直到对方回合结束时上升自身的等级×100
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：手卡·场上的这张卡作为融合素材被送去墓地或被除外
function c81555617.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：「死狱乡的凶剧」以外的自己墓地或除外状态的「死狱乡」怪兽或8星以上融合怪兽且可以特殊召唤
function c81555617.spfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not c:IsCode(81555617) and c:IsSetCard(0x164) or c:IsLevelAbove(8) and c:IsType(TYPE_FUSION))
end
-- ②效果的发动准备：选择「死狱乡的凶剧」以外的自己墓地或除外状态的1只「死狱乡」怪兽或8星以上的融合怪兽为对象才能发动
function c81555617.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c81555617.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地或除外状态存在至少1只可以作为对象的符合特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c81555617.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地或除外状态的1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c81555617.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：包含特殊召唤选定对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的执行：将选择的对象怪兽特殊召唤
function c81555617.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
