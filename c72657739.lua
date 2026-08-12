--怨念のキラードール
-- 效果：
-- 这张卡因永续魔法的效果从场上送去墓地的场合，自己的回合的准备阶段时从墓地特殊召唤。
function c72657739.initial_effect(c)
	-- 这张卡因永续魔法的效果从场上送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c72657739.regop)
	c:RegisterEffect(e1)
end
-- 在送去墓地时，检测是否满足‘因永续魔法的效果从场上送去墓地’的条件，若满足则注册在准备阶段发动的特殊召唤效果
function c72657739.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
		and re:GetActiveType()==TYPE_CONTINUOUS+TYPE_SPELL then
		-- 自己的回合的准备阶段时从墓地特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(72657739,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCondition(c72657739.spcon)
		e1:SetTarget(c72657739.sptg)
		e1:SetOperation(c72657739.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件函数
function c72657739.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤效果的发动准备与目标确认函数
function c72657739.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理函数
function c72657739.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无可用区域则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地的这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
