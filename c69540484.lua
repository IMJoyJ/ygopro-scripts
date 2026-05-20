--クシャトリラ・バース
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己在7星怪兽召唤的场合需要的解放可以不用。
-- ②：自己主要阶段才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选超量怪兽以外的1只「俱舍怒威族」怪兽特殊召唤。
-- ③：对方把魔法卡的效果发动的场合，若自己场上有「俱舍怒威族」怪兽存在，以对方墓地3张卡为对象才能发动。那些卡里侧表示除外。
function c69540484.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在7星怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69540484,0))  --"使用「俱舍怒威族的停泊地」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1,69540484)
	e2:SetCondition(c69540484.ntcon)
	e2:SetTarget(c69540484.nttg)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从自己墓地的怪兽以及除外的自己怪兽之中选超量怪兽以外的1只「俱舍怒威族」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69540484,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,69540485)
	e3:SetTarget(c69540484.sptg)
	e3:SetOperation(c69540484.spop)
	c:RegisterEffect(e3)
	-- ③：对方把魔法卡的效果发动的场合，若自己场上有「俱舍怒威族」怪兽存在，以对方墓地3张卡为对象才能发动。那些卡里侧表示除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69540484,2))  --"对方墓地3张卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,69540486)
	e4:SetCondition(c69540484.rmcon)
	e4:SetTarget(c69540484.rmtg)
	e4:SetOperation(c69540484.rmop)
	c:RegisterEffect(e4)
end
-- 召唤规则效果的条件判定函数（判定是否可以不用解放进行召唤）
function c69540484.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定需要的解放怪兽数量为0，且自己场上有可用的怪兽区域
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 召唤规则效果的目标过滤函数（仅适用于7星怪兽）
function c69540484.nttg(e,c)
	return c:IsLevel(7)
end
-- 过滤满足特殊召唤条件的超量怪兽以外的「俱舍怒威族」怪兽（存在于墓地或除外区且表侧表示）
function c69540484.spfilter(c,e,tp)
	return c:IsSetCard(0x189) and not c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检查函数
function c69540484.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外区是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c69540484.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示将从墓地或除外区特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤效果的执行函数
function c69540484.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地或除外区选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69540484.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「俱舍怒威族」怪兽
function c69540484.rmcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- 判定发动条件：对方把魔法卡的效果发动
function c69540484.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
-- 除外效果的发动准备与目标选择函数
function c69540484.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 检查对方墓地是否存在至少3张可以里侧表示除外的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,3,nil,tp,POS_FACEDOWN)
		-- 检查自己场上是否存在「俱舍怒威族」怪兽
		and Duel.IsExistingMatchingCard(c69540484.rmcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地3张卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,3,3,nil,tp,POS_FACEDOWN)
	-- 设置连锁处理中的操作信息，表示将除外选中的对象卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 除外效果的执行函数
function c69540484.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		-- 将这些卡片里侧表示除外
		Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)
	end
end
