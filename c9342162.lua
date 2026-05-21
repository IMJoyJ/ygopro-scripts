--彼岸の悪鬼 ハロウハウンド
-- 效果：
-- 「彼岸的恶鬼 卡尼亚佐」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「彼岸」魔法·陷阱卡送去墓地。
function c9342162.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c9342162.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9342162,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,9342162)
	e2:SetCondition(c9342162.sscon)
	e2:SetTarget(c9342162.sstg)
	e2:SetOperation(c9342162.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「彼岸」魔法·陷阱卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9342162,1))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,9342162)
	e3:SetTarget(c9342162.tgtg)
	e3:SetOperation(c9342162.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示怪兽或者非「彼岸」怪兽
function c9342162.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自我破坏效果的判定条件
function c9342162.sdcon(e)
	-- 检查自己场上是否存在里侧表示怪兽或非「彼岸」怪兽
	return Duel.IsExistingMatchingCard(c9342162.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法·陷阱卡
function c9342162.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 手卡特殊召唤效果的发动条件
function c9342162.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c9342162.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 手卡特殊召唤效果的发动准备与合法性检测
function c9342162.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特殊召唤效果的执行
function c9342162.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡组中可以送去墓地的「彼岸」魔法·陷阱卡
function c9342162.tgfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 送去墓地效果的发动准备与合法性检测
function c9342162.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查卡组中是否存在可送去墓地的「彼岸」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9342162.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送去墓地效果的执行
function c9342162.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「彼岸」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c9342162.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
