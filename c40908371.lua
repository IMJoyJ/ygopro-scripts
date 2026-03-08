--蒼眼の銀龍
-- 效果：
-- 调整＋调整以外的通常怪兽1只以上
-- ①：这张卡特殊召唤的场合发动。自己场上的全部龙族怪兽直到下个回合的结束时不会被效果破坏，双方直到下个回合的结束时不能把那些作为效果的对象。
-- ②：自己准备阶段，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c40908371.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的通常怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_NORMAL),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合发动。自己场上的全部龙族怪兽直到下个回合的结束时不会被效果破坏，双方直到下个回合的结束时不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40908371,0))  --"效果耐性"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c40908371.effop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40908371,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c40908371.spcon)
	e2:SetTarget(c40908371.sptg)
	e2:SetOperation(c40908371.spop)
	c:RegisterEffect(e2)
end
-- 过滤场上正面表示的龙族怪兽
function c40908371.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 为场上所有龙族怪兽设置效果，使其在下个回合结束前不会被效果破坏
function c40908371.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有正面表示的龙族怪兽
	local g=Duel.GetMatchingGroup(c40908371.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽在下个回合结束前不会被效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 使目标怪兽在下个回合结束前不能成为效果的对象
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 判断是否为自己的准备阶段
function c40908371.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤墓地中的通常怪兽
function c40908371.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和目标选择
function c40908371.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40908371.spfilter(chkc,e,tp) end
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c40908371.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的1只通常怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c40908371.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c40908371.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
