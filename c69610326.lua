--覇王眷竜ダークヴルム
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，自己场上没有怪兽存在的场合才能发动。从卡组把1只「霸王门」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能灵摆召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「霸王门」灵摆怪兽加入手卡。
-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
function c69610326.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（灵摆召唤、作为灵摆卡发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己场上没有怪兽存在的场合才能发动。从卡组把1只「霸王门」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69610326,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c69610326.pccon)
	e1:SetTarget(c69610326.pctg)
	e1:SetOperation(c69610326.pcop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「霸王门」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69610326,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,69610326)
	e2:SetTarget(c69610326.thtg)
	e2:SetOperation(c69610326.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69610326,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,69610327)
	e4:SetCondition(c69610326.pccon)
	e4:SetTarget(c69610326.sptg)
	e4:SetOperation(c69610326.spop)
	c:RegisterEffect(e4)
end
-- 定义灵摆效果/墓地特召效果的发动条件函数
function c69610326.pccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义卡组中「霸王门」灵摆怪兽的过滤条件
function c69610326.pcfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 定义灵摆效果的发动靶向函数
function c69610326.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己左或右灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否存在至少1张满足过滤条件的「霸王门」灵摆怪兽
		and Duel.IsExistingMatchingCard(c69610326.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义灵摆效果的效果处理函数
function c69610326.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能灵摆召唤。/①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「霸王门」灵摆怪兽加入手卡。/②：这张卡在墓地存在，自己场上没有怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c69610326.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，适用非暗属性怪兽不能灵摆召唤的限制
	Duel.RegisterEffect(e1,tp)
	-- 检查灵摆区域是否仍有空位，若无则结束处理
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 给玩家发送选择卡片放置到场上的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张满足条件的「霸王门」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c69610326.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示放置到自己的灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 定义非暗属性怪兽不能灵摆召唤的限制条件函数
function c69610326.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 定义卡组中可检索的「霸王门」灵摆怪兽的过滤条件
function c69610326.thfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 定义检索效果的发动靶向函数
function c69610326.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可检索的「霸王门」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69610326.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索效果的效果处理函数
function c69610326.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择卡片加入手牌的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的「霸王门」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c69610326.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义墓地特召效果的发动靶向函数
function c69610326.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为“将这张卡特殊召唤”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义墓地特召效果的效果处理函数
function c69610326.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，且自己场上仍有空余的怪兽区域
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
