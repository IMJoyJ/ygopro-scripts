--彼岸の悪鬼 バルバリッチャ
-- 效果：
-- 「彼岸的恶鬼 巴尔巴里恰」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以「彼岸的恶鬼 巴尔巴里恰」以外的自己墓地最多3张「彼岸」卡为对象才能发动。那些卡除外，给与对方除外数量×300伤害。
function c81992475.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c81992475.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81992475,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,81992475)
	e2:SetCondition(c81992475.sscon)
	e2:SetTarget(c81992475.sstg)
	e2:SetOperation(c81992475.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以「彼岸的恶鬼 巴尔巴里恰」以外的自己墓地最多3张「彼岸」卡为对象才能发动。那些卡除外，给与对方除外数量×300伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81992475,1))  --"效果伤害"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,81992475)
	e3:SetTarget(c81992475.rmtg)
	e3:SetOperation(c81992475.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示怪兽或者非「彼岸」怪兽
function c81992475.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自我破坏效果的发生条件：自己场上存在非「彼岸」怪兽（或里侧怪兽）
function c81992475.sdcon(e)
	-- 检查自己场上是否存在满足过滤条件（里侧或非「彼岸」）的怪兽
	return Duel.IsExistingMatchingCard(c81992475.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c81992475.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 特殊召唤效果的发动条件：自己场上没有魔法·陷阱卡存在
function c81992475.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c81992475.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动检测：检查怪兽区域是否有空位且自身能否特殊召唤
function c81992475.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将自身特殊召唤
function c81992475.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：墓地中「彼岸的恶鬼 巴尔巴里恰」以外的「彼岸」卡，且可以被除外
function c81992475.rmfilter(c)
	return c:IsSetCard(0xb1) and not c:IsCode(81992475) and c:IsAbleToRemove()
end
-- 除外并伤害效果的发动检测：选择墓地的除外对象并设置操作信息
function c81992475.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81992475.rmfilter(chkc) end
	-- 检查自己墓地是否存在至少1张满足过滤条件的「彼岸」卡
	if chk==0 then return Duel.IsExistingTarget(c81992475.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1到3张满足过滤条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c81992475.rmfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置连锁中的操作信息：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_GRAVE)
	-- 设置连锁中的操作信息：给与对方除外数量×300的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*300)
end
-- 除外并伤害效果的执行：除外对象卡片并给与对方相应数值的伤害
function c81992475.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若存在有效的对象卡，则将其表侧表示除外，并检查是否成功除外
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取上一步实际被除外的卡片组
		local rg=Duel.GetOperatedGroup()
		local ct=rg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		if ct>0 then
			-- 给与对方实际除外数量×300的伤害
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
