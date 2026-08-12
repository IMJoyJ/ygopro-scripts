--旧神ヌトス
-- 效果：
-- 同调怪兽＋超量怪兽
-- 把自己场上的上记的卡送去墓地的场合才能特殊召唤。自己对「旧神 努茨」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只4星怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c80532587.initial_effect(c)
	c:SetSPSummonOnce(80532587)
	c:EnableReviveLimit()
	-- 设置融合素材为同调怪兽和超量怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_SYNCHRO),aux.FilterBoolFunction(Card.IsFusionType,TYPE_XYZ),false)
	-- 设置接触融合召唤手续：将自己场上的素材作为代价送去墓地
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	-- 把自己场上的上记的卡送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只4星怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80532587,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c80532587.sptg)
	e3:SetOperation(c80532587.spop)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80532587,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(c80532587.destg)
	e4:SetOperation(c80532587.desop)
	c:RegisterEffect(e4)
end
-- 过滤手卡中可以特殊召唤的4星怪兽
function c80532587.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（手卡特殊召唤）的发动准备与可行性检测函数
function c80532587.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只满足特召条件的4星怪兽
		and Duel.IsExistingMatchingCard(c80532587.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果①（手卡特殊召唤）的效果处理函数
function c80532587.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特召条件的4星怪兽
	local g=Duel.SelectMatchingCard(tp,c80532587.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②（送墓破坏）的发动准备与对象选择函数
function c80532587.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②（送墓破坏）的效果处理函数
function c80532587.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
