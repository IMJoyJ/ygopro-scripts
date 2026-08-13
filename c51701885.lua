--テレポンD.D.
-- 效果：
-- 自己场上表侧表示存在的这张卡从游戏中除外的场合，可以从自己卡组把1只攻击力1500以下的念动力族怪兽从游戏中除外。下次的自己的准备阶段时，这个效果除外的怪兽特殊召唤。
function c51701885.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡从游戏中除外的场合，可以从自己卡组把1只攻击力1500以下的念动力族怪兽从游戏中除外。
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
	-- 下次的自己的准备阶段时，这个效果除外的怪兽特殊召唤。
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
-- 效果发动条件：此卡在场上表侧表示存在时被除外（即除外前位于场上且为表侧表示）。
function c51701885.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤条件：攻击力1500以下、念动力族、且能够被除外的卡。
function c51701885.filter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 效果发动时：若卡组存在满足条件的怪兽则允许发动，并设定将除外的操作信息。
function c51701885.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：卡组中是否存在至少1只满足条件的念动力族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c51701885.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本次效果将把1张卡组中的卡除外，用于后续效果检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的念动力族怪兽除外，并给除外怪兽及这张卡设置标记，以便下次准备阶段特殊召唤。
function c51701885.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己卡组选择1张满足filter条件的念动力族怪兽。
	local g=Duel.SelectMatchingCard(tp,c51701885.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 将选中的怪兽以表侧表示形式从游戏中除外（效果除外）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if c:IsRelateToEffect(e) then
			c:RegisterFlagEffect(51701885,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,3)
			tc:RegisterFlagEffect(51701885,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,3)
			e:SetLabelObject(tc)
		end
	end
end
-- 特殊召唤触发条件：被除外的那只怪兽仍被记录，且到下次自己的准备阶段，同时这张卡和该怪兽都持有已标记的除外记录。
function c51701885.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	local c=e:GetHandler()
	-- 判断时间点是否为下次自己的准备阶段：当前回合数不等于该怪兽被除外时的回合数，且当前回合玩家是自己。
	return tc and Duel.GetTurnCount()~=tc:GetTurnID() and Duel.GetTurnPlayer()==tp
		and c:GetFlagEffect(51701885)~=0 and tc:GetFlagEffect(51701885)~=0
end
-- 特殊召唤效果发动时：确认被除外的怪兽能否特殊召唤，建立效果关联，并清除这张卡上的标记。
function c51701885.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	e:GetHandler():ResetFlagEffect(51701885)
	-- 设定操作信息：本次效果将特殊召唤该被除外的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 特殊召唤效果处理：如果记录的怪兽仍与本次效果关联，则将其特殊召唤。
function c51701885.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将被除外的该怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
