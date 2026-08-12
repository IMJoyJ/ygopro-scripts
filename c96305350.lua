--GP－キャプテン・キャリー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「黄金荣耀」陷阱卡加入手卡。
-- ③：这张卡被送去墓地的场合，以从额外卡组特殊召唤的自己场上1只「黄金荣耀」怪兽为对象才能发动。从自己墓地把最多3张「黄金荣耀」卡除外，作为对象的怪兽的攻击力上升除外数量×500。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（包含手卡特召、召唤/特召检索陷阱、送墓上升场上怪兽攻击力三个效果）
function s.initial_effect(c)
	-- ①：自己基本分比对方少的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「黄金荣耀」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以从额外卡组特殊召唤的自己场上1只「黄金荣耀」怪兽为对象才能发动。从自己墓地把最多3张「黄金荣耀」卡除外，作为对象的怪兽的攻击力上升除外数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 效果①的特殊召唤发动条件函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否比对方少
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 效果①的特殊召唤发动准备与检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的特殊召唤处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将此卡在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤卡组中「黄金荣耀」陷阱卡的条件函数
function s.filter(c)
	return c:IsSetCard(0x192) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的检索发动准备与检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「黄金荣耀」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的检索处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「黄金荣耀」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示且从额外卡组特殊召唤的「黄金荣耀」怪兽的条件函数
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x192) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤墓地中可除外的「黄金荣耀」卡的条件函数
function s.rfilter(c)
	return c:IsSetCard(0x192) and c:IsAbleToRemove()
end
-- 效果③的除外并上升攻击力发动准备与检测函数
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.afilter(chkc) end
	-- 检查自己场上是否存在符合条件的「黄金荣耀」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己墓地是否存在可除外的「黄金荣耀」卡
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「黄金荣耀」怪兽作为效果对象
	Duel.SelectTarget(tp,s.afilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置从墓地除外卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的除外并上升攻击力处理函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择最多3张「黄金荣耀」卡
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	if #g==0 then return end
	-- 将选中的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if ct>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 作为对象的怪兽的攻击力上升除外数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*500)
		tc:RegisterEffect(e1)
	end
end
