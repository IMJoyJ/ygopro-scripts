--テレポンD.D.
-- 效果：
-- 自己场上表侧表示存在的这张卡从游戏中除外的场合，可以从自己卡组把1只攻击力1500以下的念动力族怪兽从游戏中除外。下次的自己的准备阶段时，这个效果除外的怪兽特殊召唤。
function c51701885.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡从游戏中除外的场合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51701885,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c51701885.rmcon)
	e1:SetTarget(c51701885.rmtg)
	e1:SetOperation(c51701885.rmop)
	c:RegisterEffect(e1)
	-- 下次的自己的准备阶段时，这个效果除外的怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51701885,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c51701885.spcon)
	e2:SetTarget(c51701885.sptg)
	e2:SetOperation(c51701885.spop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断该卡是否从场上被除外
function c51701885.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤满足攻击力1500以下、念动力族且可除外的怪兽
function c51701885.filter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 设置效果发动时的处理目标为从卡组除外1只符合条件的怪兽
function c51701885.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51701885.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 执行除外怪兽并记录flag的逻辑
function c51701885.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51701885.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 将选中的怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if c:IsRelateToEffect(e) then
			c:RegisterFlagEffect(51701885,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,3)
			tc:RegisterFlagEffect(51701885,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,3)
			e:SetLabelObject(tc)
		end
	end
end
-- 判断是否满足特殊召唤条件：回合未结束且双方flag有效
function c51701885.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	local c=e:GetHandler()
	-- 判断当前回合是否与怪兽被除外时不同，且为自己的回合
	return tc and Duel.GetTurnCount()~=tc:GetTurnID() and Duel.GetTurnPlayer()==tp
		and c:GetFlagEffect(51701885)~=0 and tc:GetFlagEffect(51701885)~=0
end
-- 设置特殊召唤的处理目标为之前除外的怪兽
function c51701885.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	e:GetHandler():ResetFlagEffect(51701885)
	-- 设置操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 执行特殊召唤操作
function c51701885.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
