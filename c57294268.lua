--追憶のアレイスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以场上1只魔法师族怪兽或融合怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力直到回合结束时上升1000。
-- ②：这张卡召唤·特殊召唤·反转的场合，从额外卡组把1只「召唤兽」怪兽除外才能发动。把1张「召唤魔术」或者有那个卡名记述的魔法卡从卡组加入手卡。
local s,id,o=GetID()
-- 注册效果①（手卡特召并加攻）与效果②（召唤·特召·反转时检索）
function s.initial_effect(c)
	-- 在卡片关系中记录这张卡记述了卡片密码为74063034（召唤魔术）的卡片
	aux.AddCodeList(c,74063034)
	-- ①：这张卡在手卡存在的场合，以场上1只魔法师族怪兽或融合怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤·反转的场合，从额外卡组把1只「召唤兽」怪兽除外才能发动。把1张「召唤魔术」或者有那个卡名记述的魔法卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end
-- 过滤函数：场上表侧表示的融合怪兽或魔法师族怪兽
function s.spfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_FUSION) or c:IsRace(RACE_SPELLCASTER))
end
-- 效果①的判定与对象选择函数：检查玩家场上是否有空闲怪兽区，自身是否能特殊召唤，以及场上是否存在满足过滤条件的融合怪兽或魔法师族怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) end
	-- 若为效果发动的检查（chk==0），则判定己方场上的怪兽区域空格数是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 以及判定场上是否存在可以作为效果对象的表侧表示融合怪兽或魔法师族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 发送系统提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的融合怪兽或魔法师族怪兽作为效果的对象
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，若特殊召唤成功，则作为对象的怪兽攻击力上升1000直到回合结束
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若自身仍在手卡中且能成功特殊召唤，并且对象怪兽在场上以表侧表示存在，则进行攻击力提升处理
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToChain() and tc:IsFaceup() then
		-- 作为对象的怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：额外卡组中属于「召唤兽」字段且可以被除外的卡
function s.cfilter(c)
	return c:IsSetCard(0xf4) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost处理：从额外卡组把1只「召唤兽」怪兽除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为效果发动的检查（chk==0），则判定额外卡组中是否存在可以用于除外的「召唤兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 发送系统提示：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择额外卡组中1只用于除外的「召唤兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的「召唤兽」怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中卡名为「召唤魔术」，或是记载有「召唤魔术」卡名且为魔法卡的卡片，且该卡可以加入手卡
function s.thfilter(c)
	-- 判定卡片是否为「召唤魔术」，或者是否是记载了「召唤魔术」卡名的魔法卡，并能加入手卡
	return (c:IsCode(74063034) or aux.IsCodeListed(c,74063034) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果②的发动判定：检查卡组中是否存在可以检索的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为效果发动的检查（chk==0），则判定卡组中是否存在可以加入手牌的「召唤魔术」或有那个卡名记述的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张符合条件的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1张「召唤魔术」或者有那个卡名记述的魔法卡加入手卡并向对方玩家确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「召唤魔术」或者有那个卡名记述的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
