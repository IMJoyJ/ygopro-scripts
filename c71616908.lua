--ジェムナイト・アメジス
-- 效果：
-- 「宝石骑士」怪兽＋水族怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡从场上送去墓地的场合发动。场上的里侧表示的魔法·陷阱卡全部回到手卡。
function c71616908.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤素材：1只「宝石骑士」怪兽和1只水族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c71616908.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡从场上送去墓地的场合发动。场上的里侧表示的魔法·陷阱卡全部回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71616908,0))  --"盖放的魔法·陷阱卡全部回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c71616908.thcon)
	e3:SetTarget(c71616908.thtg)
	e3:SetOperation(c71616908.thop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤条件，若从额外卡组特殊召唤，则必须是融合召唤
function c71616908.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 判断发动条件：这张卡是否是从场上送去墓地
function c71616908.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动的目标选择与操作信息设置，获取场上所有里侧表示的魔法·陷阱卡并设置回手卡的操作信息
function c71616908.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方魔法与陷阱区域所有里侧表示的卡片
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 设置连锁处理的操作信息，表示将上述里侧表示的魔法·陷阱卡全部送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，获取场上所有里侧表示的魔法·陷阱卡并将其送回手卡
function c71616908.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方魔法与陷阱区域所有里侧表示的卡片
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	-- 因效果将上述里侧表示的魔法·陷阱卡全部送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
