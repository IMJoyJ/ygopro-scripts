--オッドアイズ・メテオバースト・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「异色眼陨火龙」的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功时，以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。这个回合，这张卡不能攻击。
-- ②：只要这张卡在怪兽区域存在，对方在战斗阶段中不能把怪兽的效果发动。
function c80696379.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「异色眼陨火龙」的①的效果1回合只能使用1次。①：这张卡特殊召唤成功时，以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。这个回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80696379,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,80696379)
	e1:SetTarget(c80696379.sptg)
	e1:SetOperation(c80696379.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方在战斗阶段中不能把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c80696379.condition)
	e2:SetValue(c80696379.aclimit)
	c:RegisterEffect(e2)
end
-- 过滤可以特殊召唤的卡片
function c80696379.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动判定与对象选择
function c80696379.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c80696379.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的灵摆区域是否存在可以特殊召唤的卡
		and Duel.IsExistingTarget(c80696379.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己灵摆区域的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,c80696379.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理（特殊召唤对象卡，并使自身在这个回合不能攻击）
function c80696379.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检查当前是否处于战斗阶段
function c80696379.condition(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 限制发动的效果类型为怪兽的效果
function c80696379.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
