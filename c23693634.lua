--ギガンテック・ファイター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡的攻击力上升双方墓地的战士族怪兽数量×100的数值。这张卡被战斗破坏送去墓地时，可以选择自己或者对方的墓地1只战士族怪兽在自己场上特殊召唤。
function c23693634.initial_effect(c)
	-- 给这张卡添加同调召唤手续，要求素材为“调整＋调整以外的怪兽1只以上”（对应效果原文的召唤素材条件）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：“这张卡的攻击力上升双方墓地的战士族怪兽数量×100的数值。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c23693634.atkval)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡被战斗破坏送去墓地时，可以选择自己或者对方的墓地1只战士族怪兽在自己场上特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23693634,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c23693634.sumcon)
	e2:SetTarget(c23693634.sumtg)
	e2:SetOperation(c23693634.sumop)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升数值的计算函数：这张卡的攻击力上升双方墓地的战士族怪兽数量×100的数值。
function c23693634.atkval(e,c)
	-- 统计以这张卡控制者视角、双方墓地中满足战士族种族的卡的数量，并乘以100作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_WARRIOR)*100
end
-- 判断诱发条件：这张卡被战斗破坏送去墓地后位于墓地，且破坏原因为战斗破坏（即“被战斗破坏送去墓地时”）。
function c23693634.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLocation()==LOCATION_GRAVE
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 定义可选择对象的过滤条件：对象必须是战士族怪兽，并且能被该效果特殊召唤（通过苏生限制和召唤条件检查）。
function c23693634.filter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理：检查合法性、是否存在空位和可选对象，选择1张墓地战士族怪兽作为对象，并设置特殊召唤的操作信息。
function c23693634.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c23693634.filter(chkc,e,tp) end
	-- 发动时检查自己场上是否有可用的主要怪兽区域空格，确保有空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认双方墓地存在至少1张符合条件的战士族怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c23693634.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1张符合条件的战士族怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c23693634.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行特殊召唤，对象为已经选择的1张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的实际操作：若对象卡仍与效果关联且仍为战士族，则将其特殊召唤到自己场上。
function c23693634.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1张目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将目标卡以表侧表示特殊召唤到自己场上，并进行召唤条件与苏生限制的检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
