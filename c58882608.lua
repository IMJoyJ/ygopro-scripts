--ティスティナの息吹
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「提斯蒂娜」怪兽召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动（自己场上有光属性「提斯蒂娜」怪兽存在的场合，也能作为代替以对方场上1只表侧表示怪兽为对象）。那只怪兽变成里侧守备表示。那之后，「提斯蒂娜的息吹」以外的1张「提斯蒂娜」卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化并注册卡片效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「提斯蒂娜」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「提斯蒂娜的息吹」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置额外召唤的限制条件为「提斯蒂娜」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a4))
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只表侧表示怪兽为对象才能发动（自己场上有光属性「提斯蒂娜」怪兽存在的场合，也能作为代替以对方场上1只表侧表示怪兽为对象）。那只怪兽变成里侧守备表示。那之后，「提斯蒂娜的息吹」以外的1张「提斯蒂娜」卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的光属性「提斯蒂娜」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(0x1a4)
end
-- 过滤条件：卡组中「提斯蒂娜的息吹」以外的可检索「提斯蒂娜」卡
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ②效果的发动合法性检测与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在光属性「提斯蒂娜」怪兽，以决定是否能选择对方场上的怪兽
	local b=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and (chkc:IsControler(tp) or b) and chkc:IsCanTurnSet() end
	local loc2=0
	if b then loc2=LOCATION_MZONE end
	-- 在发动时，检测是否存在可以变成里侧守备表示的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,loc2,1,nil)
		-- 以及卡组中是否存在可检索的卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择要变成里侧表示的怪兽作为对象（若满足条件则可选对方场上的怪兽）
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,loc2,1,1,nil)
	-- 设置效果分类为改变表示形式，并注册操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置效果分类为检索，并注册操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理逻辑
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果，则将其变成里侧守备表示，若操作失败则不进行后续处理
	if not tc:IsRelateToEffect(e) or Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)<1 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「提斯蒂娜的息吹」以外的「提斯蒂娜」卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 中断效果处理，使改变表示形式与检索不视为同时处理
		Duel.BreakEffect()
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
