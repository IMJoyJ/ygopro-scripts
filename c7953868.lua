--蒼血鬼
-- 效果：
-- 这张卡召唤·反转召唤成功时，变成守备表示。1回合1次，可以把自己场上存在的1个超量素材取除，选择自己墓地存在的1只4星的不死族怪兽特殊召唤。
function c7953868.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7953868,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c7953868.potg)
	e1:SetOperation(c7953868.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把自己场上存在的1个超量素材取除，选择自己墓地存在的1只4星的不死族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7953868,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c7953868.spcost)
	e3:SetTarget(c7953868.sptg)
	e3:SetOperation(c7953868.spop)
	c:RegisterEffect(e3)
end
-- 变成守备表示效果的Target函数（发动准备与检测）
function c7953868.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置操作信息：将自身表示形式改变
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 变成守备表示效果的Operation函数（效果处理）
function c7953868.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 特殊召唤效果的Cost函数（取除超量素材）
function c7953868.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为代价取除的1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 取除自己场上的1个超量素材作为发动代价
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 过滤条件：自己墓地存在的4星不死族怪兽且可以特殊召唤
function c7953868.filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target函数（选择目标）
function c7953868.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7953868.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的怪兽作为效果对象
		and Duel.IsExistingTarget(c7953868.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7953868.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的Operation函数（效果处理）
function c7953868.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
