--紋章獣ユニコーン
-- 效果：
-- 把墓地的这张卡从游戏中除外，选择自己墓地1只念动力族超量怪兽才能发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「纹章兽 独角兽」的效果1回合只能使用1次。
function c45705025.initial_effect(c)
	-- 把墓地的这张卡从游戏中除外，选择自己墓地1只念动力族超量怪兽才能发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「纹章兽 独角兽」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45705025,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,45705025)
	-- 设置发动代价：将墓地的这张卡从游戏中除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45705025.target)
	e1:SetOperation(c45705025.operation)
	c:RegisterEffect(e1)
end
-- 定义目标筛选条件：候选卡必须是念动力族超量怪兽，且能够被当前效果特殊召唤（满足苏生限制）。
function c45705025.filter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的条件判定与取对象处理：检查自己场上是否有特殊召唤空位，且墓地存在至少1只满足条件的念动力族超量怪兽；若为选择对象阶段，则验证所选卡满足条件并位于自己墓地，将其设为效果对象。
function c45705025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45705025.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区域是否有空位，确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的念动力族超量怪兽（且能成为效果对象），并排除此卡自身。
		and Duel.IsExistingTarget(c45705025.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的念动力族超量怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c45705025.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息，声明本次效果将特殊召唤对象怪兽（数量1），供连锁处理时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象怪兽，确认其仍与效果关联后将其以表侧表示特殊召唤，并对其附加效果无效化状态，最后完成特殊召唤处理。
function c45705025.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍与效果关联，若关联则尝试将其以表侧表示特殊召唤；若特殊召唤成功，则继续执行后续的无效化处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，将临时累积的特殊召唤操作统一生效。
	Duel.SpecialSummonComplete()
end
