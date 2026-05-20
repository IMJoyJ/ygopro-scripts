--メメント・エンウィッチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「莫忘天魔女」以外的1只「莫忘」怪兽加入手卡。
-- ②：以自己墓地1只2星以下的「莫忘」怪兽为对象才能发动。自己场上1只「莫忘」怪兽破坏，作为对象的怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（包含召唤·特殊召唤成功时检索「莫忘」怪兽，以及起动效果破坏场上「莫忘」怪兽并特召墓地2星以下「莫忘」怪兽）
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「莫忘天魔女」以外的1只「莫忘」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己墓地1只2星以下的「莫忘」怪兽为对象才能发动。自己场上1只「莫忘」怪兽破坏，作为对象的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中「莫忘天魔女」以外的「莫忘」怪兽
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果①（检索）的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的「莫忘」怪兽，且该怪兽离开后能空出可用的怪兽区域
function s.cfilter(c,tp)
	-- 检查卡片是否为表侧表示的「莫忘」怪兽，且其离开场上后能提供至少1个可用的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0x1a1) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤条件：墓地中2星以下且可以特殊召唤的「莫忘」怪兽
function s.sfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsSetCard(0x1a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（破坏并特召）的发动准备与对象选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 检查自己场上是否存在可作为破坏对象的「莫忘」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查自己墓地是否存在可作为特召对象的2星以下「莫忘」怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：破坏自己场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
	-- 设置连锁处理信息：特殊召唤作为对象的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（破坏并特召）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只用于破坏的「莫忘」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 若成功破坏选择的怪兽，且作为对象的墓地怪兽仍在该效果影响下
	if Duel.Destroy(g,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
