--ギガンテック・ファイター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡的攻击力上升双方墓地的战士族怪兽数量×100的数值。这张卡被战斗破坏送去墓地时，可以选择自己或者对方的墓地1只战士族怪兽在自己场上特殊召唤。
function c23693634.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡的攻击力上升双方墓地的战士族怪兽数量×100的数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c23693634.atkval)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，可以选择自己或者对方的墓地1只战士族怪兽在自己场上特殊召唤
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
-- 计算双方墓地的战士族怪兽数量并乘以100作为攻击力上升值
function c23693634.atkval(e,c)
	-- 检索双方墓地的战士族怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_WARRIOR)*100
end
-- 判断该卡是否因战斗破坏而进入墓地
function c23693634.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLocation()==LOCATION_GRAVE
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 过滤出可以特殊召唤的战士族怪兽
function c23693634.filter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和目标选择
function c23693634.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c23693634.filter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方墓地是否存在满足条件的战士族怪兽
		and Duel.IsExistingTarget(c23693634.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送选择特殊召唤目标的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一个满足条件的战士族怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c23693634.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c23693634.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
