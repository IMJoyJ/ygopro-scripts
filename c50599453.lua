--枯鰈葉リプレース
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，对方墓地的卡数量比自己墓地的卡多的场合，自己准备阶段才能发动。这张卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升对方墓地的卡数量×200。
function c50599453.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，对方墓地的卡数量比自己墓地的卡多的场合，自己准备阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,50599453)
	e1:SetCondition(c50599453.spcon)
	e1:SetTarget(c50599453.sptg)
	e1:SetOperation(c50599453.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升对方墓地的卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c50599453.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 定义①效果的发动条件判定函数：判断是否满足对方墓地的卡数量比自己墓地的卡多，且当前为这张卡控制者的准备阶段。
function c50599453.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件具体为：tp是当前回合玩家（即现在是tp的准备阶段），且tp视角下对方墓地卡数大于自己墓地卡数。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)
end
-- 定义①效果的Target函数，在发动时检查自己主要怪兽区是否有空位，且这张卡能够被特殊召唤（无取对象）。
function c50599453.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性检查）时，确认存在可用主要怪兽区域，且这张卡满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行特殊召唤的操作信息：对象为这张卡自身，数量1，目标玩家和区域未知，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果处理函数：若这张卡仍与效果关联（未因离场断开联系），则进行特殊召唤。
function c50599453.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到tp的场上，并正常检查特殊召唤条件与苏生限制。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的攻守上升值计算函数：每次适用时根据对方墓地卡数动态计算上升数值。
function c50599453.adval(e,c)
	-- 返回这张卡控制者视角下对方墓地的卡数量乘以200，作为攻击力/守备力上升值。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)*200
end
