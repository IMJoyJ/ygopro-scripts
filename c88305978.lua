--BF－陽炎のカーム
-- 效果：
-- 对方的战斗阶段时，自己场上没有怪兽存在的场合，把墓地存在的这张卡从游戏中除外才能发动。选择自己墓地存在的1只同调怪兽特殊召唤。这个效果特殊召唤的怪兽在战斗阶段结束时从游戏中除外。
function c88305978.initial_effect(c)
	-- 对方的战斗阶段时，自己场上没有怪兽存在的场合，把墓地存在的这张卡从游戏中除外才能发动。选择自己墓地存在的1只同调怪兽特殊召唤。这个效果特殊召唤的怪兽在战斗阶段结束时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88305978,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c88305978.condition)
	-- 设置发动代价为：把墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c88305978.target)
	e1:SetOperation(c88305978.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：对方的战斗阶段，且自己场上没有怪兽存在
function c88305978.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的战斗阶段
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		-- 判定自己场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：自己墓地的同调怪兽，且可以特殊召唤
function c88305978.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的目标选择：检查怪兽区域空位和墓地中符合条件的同调怪兽，并选择该怪兽作为效果对象
function c88305978.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88305978.filter(chkc,e,tp) end
	-- 在发动阶段（chk==0）时，判定自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以特殊召唤的同调怪兽
		and Duel.IsExistingTarget(c88305978.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88305978.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的同调怪兽特殊召唤，并注册在战斗阶段结束时将其除外的延迟效果
function c88305978.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(88305978,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在战斗阶段结束时从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(tc)
		e1:SetCondition(c88305978.rmcon)
		e1:SetOperation(c88305978.rmop)
		-- 注册全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟除外效果的触发条件判定：检查该怪兽是否仍带有特殊召唤时的标记，若无则重置该效果
function c88305978.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(88305978)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 延迟除外效果的处理：将该怪兽除外
function c88305978.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将该怪兽表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
