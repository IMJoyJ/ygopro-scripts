--サイバネット・ロールバック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以除外的1只自己的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己基本分是2000以下的场合，自己主要阶段把墓地的这张卡除外，以除外的2只自己的电子界族怪兽为对象才能发动。那些怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特殊召唤）和②效果（回收除外的怪兽）
function s.initial_effect(c)
	-- ①：以除外的1只自己的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下的场合，自己主要阶段把墓地的这张卡除外，以除外的2只自己的电子界族怪兽为对象才能发动。那些怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.thcon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的、电子界族的、且可以被特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（Target）函数，处理对象选择与发动条件判定
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 判定自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定除外区是否存在至少1只满足条件的自己的电子界族怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己的电子界族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该连锁将特殊召唤选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理（Operation）函数，执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个（也是唯一一个）对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc and tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的发动条件判定函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己的基本分是否在2000以下
	return Duel.GetLP(tp)<=2000
end
-- 过滤条件：表侧表示的、电子界族的、且可以加入手牌的怪兽
function s.hfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target）函数，处理对象选择与发动条件判定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定除外区是否存在至少2只满足条件的自己的电子界族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.hfilter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的2只自己的电子界族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.hfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置效果处理信息，表示该连锁将把选中的2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- ②效果的效果处理（Operation）函数，执行回收手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与当前连锁相关的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将选中的对象怪兽加入持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
