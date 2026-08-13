--転生炎獣スピニー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「转生炎兽」卡存在的场合，把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
-- ②：自己场上有「转生炎兽 犰狳蜥」以外的「转生炎兽」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c52277807.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「转生炎兽」卡存在的场合，把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52277807,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,52277807)
	e1:SetCondition(c52277807.atkcon)
	e1:SetCost(c52277807.atkcost)
	e1:SetTarget(c52277807.atktg)
	e1:SetOperation(c52277807.atkop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「转生炎兽 犰狳蜥」以外的「转生炎兽」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52277807,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,52277808)
	e2:SetCondition(c52277807.spcon)
	e2:SetTarget(c52277807.sptg)
	e2:SetOperation(c52277807.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判定卡是否为表侧表示且属于「转生炎兽」（0x119）字段的卡，用于①效果的发动条件检索。
function c52277807.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x119)
end
-- ①效果的发动条件：检查我方场上是否表侧表示存在至少1张「转生炎兽」卡（通过cfilter1过滤）。
function c52277807.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 以我方场上的所有卡为对象，检查是否存在至少1张满足cfilter1条件的表侧表示「转生炎兽」卡。
	return Duel.IsExistingMatchingCard(c52277807.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的代价：检查手卡中的这张卡能否丢弃；若能则实际丢弃作为发动代价。
function c52277807.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡以“代价+丢弃”的原因从手卡送去墓地，完成代价支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果的目标处理：选择场上1只表侧表示怪兽作为对象（取对象效果），并提供对象选择提示。
function c52277807.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 合法检测：确认场上存在可以成为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择表侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 将玩家选择的1只表侧表示怪兽设置为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：取得对象怪兽，若其仍表侧且与效果关联，则让它攻击力上升500直到回合结束。
function c52277807.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理中唯一的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：判定卡是否为表侧表示、「转生炎兽」字段，且卡名不是「转生炎兽 犰狳蜥」（52277807），用于②效果的发动条件检索。
function c52277807.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and not c:IsCode(52277807)
end
-- ②效果的发动条件：检查我方怪兽区是否存在表侧表示的、除这张卡自身以外的「转生炎兽」怪兽。
function c52277807.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 以我方怪兽区为范围，检查是否存在至少1张满足cfilter2条件的「转生炎兽」怪兽。
	return Duel.IsExistingMatchingCard(c52277807.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标/发动合法检测：确认我方主怪兽区有空位，且墓地的这张卡可以被特殊召唤。
function c52277807.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁操作为“特殊召唤墓地的这张卡”，并登记操作信息供其他卡（如星尘龙）响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将这张卡从墓地特殊召唤；若召唤成功，给它附加“从场上离开时除外”的效果。
function c52277807.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断怪卡是否仍与此效果关联，并尝试以表侧攻击表示特殊召唤这张卡，结果非0代表成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
