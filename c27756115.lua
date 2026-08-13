--超重武者装留マカルガエシ
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽1回合只有1次不会被效果破坏。
-- ③：守备表示怪兽被战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那怪兽攻击表示特殊召唤。
function c27756115.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27756115,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c27756115.eqtg)
	e1:SetOperation(c27756115.eqop)
	c:RegisterEffect(e1)
	-- ③：守备表示怪兽被战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那怪兽攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27756115,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCost(c27756115.spcost)
	e2:SetTarget(c27756115.sptg)
	e2:SetOperation(c27756115.spop)
	c:RegisterEffect(e2)
end
-- 筛选条件：作为装备对象的怪兽必须是表侧表示且属于「超重武者」系列。
function c27756115.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果①发动时的目标选择：检查魔陷区是否有空位，并选择自己场上1只表侧表示「超重武者」怪兽作为装备对象。
function c27756115.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27756115.filter(chkc) end
	-- 发动条件检查：自己魔陷区是否有空位，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：自己场上是否存在符合条件的表侧表示「超重武者」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c27756115.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家显示选择提示，提示即将选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只符合条件的「超重武者」怪兽，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,c27756115.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果①的处理：将这张卡装备给对象怪兽，同时赋予装备对象限制和1回合1次抗效果破坏的能力；若因故无法装备则把这张卡送去墓地。
function c27756115.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁处理的目标怪兽（对象）。
	local tc=Duel.GetFirstTarget()
	-- 检查装备是否满足条件：魔陷区有空位、目标怪兽控制者是自己、表侧表示且与效果关联，否则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备失败时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡以装备卡形式装备给目标怪兽。
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c27756115.eqlimit)
	c:RegisterEffect(e1)
	-- ②：用这张卡的效果把这张卡装备的怪兽1回合只有1次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c27756115.valcon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制函数：只允许装备给属于「超重武者」的怪兽。
function c27756115.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 抗破坏条件：只有破坏原因为效果破坏时才适用“不会被效果破坏”的效果。
function c27756115.valcon(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 效果③的发动代价：检查这张卡是否在手卡且可以作为代价送去墓地，并执行送墓。
function c27756115.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为效果③发动的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选墓地中满足条件的怪兽：控制者为自己、在墓地、因战斗破坏、离场前在怪兽区且为守备表示、并且可以表侧攻击表示特殊召唤。
function c27756115.cfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_DEFENSE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果③的发动条件：自己怪兽区有空位，且本次送去墓地的怪兽中存在满足条件的守备表示战斗破坏怪兽。
function c27756115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c27756115.cfilter,1,nil,e,tp) end
	local g=eg:Filter(c27756115.cfilter,nil,e,tp)
	-- 将符合条件的墓地怪兽设置为当前连锁的处理对象（不取对象）。
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明本连锁将特殊召唤1只符合条件的怪兽，供其他卡牌进行连锁反应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的处理：从墓地选择仍与效果关联的符合条件的怪兽，以表侧攻击表示特殊召唤。
function c27756115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的目标卡组（符合条件的墓地怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽以表侧攻击表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
