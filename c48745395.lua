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
	-- 这张卡的攻击力上升自己墓地的通常陷阱卡种类×400
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
-- 特殊召唤效果的发动条件判定（有陷阱卡发动）
function c48745395.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 特殊召唤效果的发动检测
function c48745395.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位并确认此卡是否可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的操作执行
function c48745395.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 特殊召唤这张卡
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中在攻击宣言时才能发动的且可在场上盖放的通常陷阱卡
function c48745395.stfilter(c)
	local te=c:GetActivateEffect()
	return c:GetType()==TYPE_TRAP and te and te:GetCode()==EVENT_ATTACK_ANNOUNCE and c:IsSSetable()
end
-- 盖放效果的发动检测
function c48745395.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c48745395.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的操作执行
function c48745395.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张符合条件的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c48745395.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤墓地中的通常陷阱卡
function c48745395.atkfilter(c)
	return c:GetType()==TYPE_TRAP
end
-- 计算攻击力上升的值（种类数量×400）
function c48745395.atkval(e,c)
	-- 获取自己墓地的所有通常陷阱卡
	local g=Duel.GetMatchingGroup(c48745395.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*400
end
-- 检查目标是否为自身以外的表侧表示恶魔族怪兽
function c48745395.atklimit(e,c)
	return c:IsFaceup() and not c:IsCode(48745395) and c:IsRace(RACE_FIEND)
end
