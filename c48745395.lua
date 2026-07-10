--白銀の城の魔神像
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选只在攻击宣言时才能作卡的发动的1张通常陷阱卡在自己场上盖放。
-- ③：这张卡的攻击力上升自己墓地的通常陷阱卡种类×400，对方不能选择「白银之城的魔神像」以外的恶魔族怪兽作为攻击对象。
function c48745395.initial_effect(c)
	-- ①：陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48745395,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,48745395)
	e1:SetCondition(c48745395.spcon)
	e1:SetTarget(c48745395.sptg)
	e1:SetOperation(c48745395.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选只在攻击宣言时才能作卡的发动的1张通常陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48745396)
	e2:SetTarget(c48745395.sttg)
	e2:SetOperation(c48745395.stop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升自己墓地的通常陷阱卡种类×400
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(c48745395.atkval)
	c:RegisterEffect(e3)
	-- 对方不能选择「白银之城的魔神像」以外的恶魔族怪兽作为攻击对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(c48745395.atklimit)
	c:RegisterEffect(e4)
end
-- 判断触发连锁的效果是否为陷阱卡的发动
function c48745395.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 检查自己场上是否有空闲的怪兽区域以及这张卡是否能从手卡特殊召唤
function c48745395.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家的主怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置在效果处理时将此卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 若此卡在效果处理时仍存在于手卡中，则将其在自己场上表侧表示特殊召唤
function c48745395.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中可以在攻击宣言时发动且可以盖放的通常陷阱卡
function c48745395.stfilter(c)
	local te=c:GetActivateEffect()
	return c:GetType()==TYPE_TRAP and te and te:GetCode()==EVENT_ATTACK_ANNOUNCE and c:IsSSetable()
end
-- 检查卡组中是否存在满足条件的、可以在攻击宣言时发动的通常陷阱卡
function c48745395.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有至少一张可以盖放的符合条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48745395.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 在卡组中选择一张符合条件的通常陷阱卡在自己场上盖放
function c48745395.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择一张符合条件的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c48745395.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡片在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 判断卡片是否为陷阱卡
function c48745395.atkfilter(c)
	return c:GetType()==TYPE_TRAP
end
-- 计算自己墓地的通常陷阱卡种类数量，并返回攻击力上升值（种类数×400）
function c48745395.atkval(e,c)
	-- 获取自己墓地中的所有陷阱卡
	local g=Duel.GetMatchingGroup(c48745395.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*400
end
-- 判断目标是否为「白银之城的魔神像」以外的表侧表示恶魔族怪兽
function c48745395.atklimit(e,c)
	return c:IsFaceup() and not c:IsCode(48745395) and c:IsRace(RACE_FIEND)
end
