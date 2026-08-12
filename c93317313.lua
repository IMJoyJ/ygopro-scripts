--DDディフェンス・ソルジャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡特殊召唤。
-- ●从自己墓地把1只「DD」怪兽除外才能发动。这个回合，自己的「DDD」怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。
-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组（表侧）·墓地把1只「DD」灵摆怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①效果（特殊召唤/效果封锁）、②效果（回收）
function s.initial_effect(c)
	-- ●以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●从自己墓地把1只「DD」怪兽除外才能发动。这个回合，自己的「DDD」怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果封锁"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.eacon)
	e2:SetCost(s.eacost)
	e2:SetOperation(s.eaop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从自己的额外卡组（表侧）·墓地把1只「DD」灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置发动②效果的Cost为：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：可以特殊召唤的「DD」卡
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果（特殊召唤）的发动准备：检查并选择灵摆区域的「DD」卡作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的灵摆区域是否存在至少1张满足特殊召唤条件的「DD」卡
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择灵摆区域的1张「DD」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤选定卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果（特殊召唤）的效果处理：将作为对象的卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为特殊召唤对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽以表侧表示特殊召唤到发动者的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ①效果（效果封锁）的发动条件：当前回合玩家可以进入战斗阶段
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：自己墓地中可以作为Cost除外的「DD」怪兽
function s.cfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果（效果封锁）的发动Cost：从自己墓地把1只「DD」怪兽除外
function s.eacost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可除外的「DD」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地中的1只「DD」怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果（效果封锁）的效果处理：注册一个全局效果，使得自己的「DDD」怪兽攻击时对方不能发动卡的效果
function s.eaop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己的「DDD」怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。②：把墓地的这张卡除外才能发动。从自己的额外卡组（表侧）·墓地把1只「DD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	-- 在全局注册该效果封锁的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果封锁的适用条件：当前进行攻击的怪兽是自己场上的「DDD」怪兽且处于战斗中
function s.actcon(e)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	return a~=nil and a:IsSetCard(0x10af) and a:IsControler(e:GetHandlerPlayer()) and a:IsRelateToBattle()
end
-- 过滤条件：额外卡组表侧表示或墓地中的「DD」灵摆怪兽，且可以加入手卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xaf)
		and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- ②效果（回收）的发动准备：检查额外卡组（表侧）或墓地是否存在可回收的「DD」灵摆怪兽，并设置回收的连锁信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组（表侧）或墓地是否存在至少1张满足条件的「DD」灵摆怪兽（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置连锁信息，表示该效果包含将额外卡组或墓地的卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- ②效果（回收）的效果处理：从额外卡组（表侧）或墓地选择1只「DD」灵摆怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从额外卡组（表侧）或墓地选择1张满足条件的「DD」灵摆怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
