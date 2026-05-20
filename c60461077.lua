--剛鬼ライジングスコーピオ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「刚鬼」怪兽的场合，这张卡可以不用解放作召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 闪光斧踢蝎」以外的1张「刚鬼」卡加入手卡。
function c60461077.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有「刚鬼」怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60461077,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c60461077.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 闪光斧踢蝎」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60461077,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,60461077)
	e2:SetCondition(c60461077.thcon)
	e2:SetTarget(c60461077.thtg)
	e2:SetOperation(c60461077.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：里侧表示怪兽或者非「刚鬼」怪兽
function c60461077.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xfc)
end
-- 不用解放作召唤的条件：自己场上没有怪兽，或者自己场上的怪兽只有「刚鬼」怪兽
function c60461077.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否是不需要解放的召唤、怪兽等级是否在5星以上、以及怪兽区域是否有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否没有怪兽，或者不存在里侧表示怪兽及非「刚鬼」怪兽（即只有表侧表示的「刚鬼」怪兽）
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c60461077.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 发动条件：这张卡从场上送去墓地
function c60461077.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中「刚鬼 闪光斧踢蝎」以外的「刚鬼」卡，且能加入手卡
function c60461077.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(60461077) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与操作信息注册
function c60461077.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查卡组中是否存在满足条件的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c60461077.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1张「刚鬼」卡加入手卡
function c60461077.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c60461077.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
