--E・HERO フレイム・ウィングマン－フレイム・シュート
-- 效果：
-- 属性不同的「元素英雄」怪兽×2
-- 这张卡不用融合召唤不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「至爱」卡加入手卡。
-- ②：把用通常怪兽为素材作融合召唤的这张卡解放才能发动。从卡组·额外卡组把1只7星以下的不能通常召唤的「元素英雄」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、特殊召唤限制、特殊召唤成功时检索「至爱」卡的效果、解放自身特殊召唤「元素英雄」怪兽的效果，以及素材检查
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤素材：2只满足过滤条件s.ffilter（属性不同的「元素英雄」怪兽）的怪兽
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为仅能通过融合召唤特殊召唤
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「至爱」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把用通常怪兽为素材作融合召唤的这张卡解放才能发动。从卡组·额外卡组把1只7星以下的不能通常召唤的「元素英雄」怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 把用通常怪兽为素材作融合召唤的这张卡解放才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
s.material_setcode=0x8
-- 融合素材过滤条件：属于「元素英雄」系列，且融合素材组中不存在相同属性的怪兽（即属性不同）
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x3008) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 融合素材检查：若融合素材中存在通常怪兽，则给这张卡注册一个标记（Flag），用于判断是否满足效果②的发动条件
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(id,RESET_EVENT+0x4fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"用通常怪兽为素材作融合召唤"
	end
end
-- 检索过滤条件：属于「至爱」系列且能加入手卡的卡片
function s.thfilter(c)
	return c:IsSetCard(0x194) and c:IsAbleToHand()
end
-- 效果①（检索「至爱」卡）的发动准备（Target阶段），检查卡组或墓地是否存在可检索卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张满足过滤条件s.thfilter的「至爱」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①（检索「至爱」卡）的效果处理（Operation阶段），从卡组或墓地选择1张「至爱」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足过滤条件且不受「王家长眠之谷」影响的「至爱」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价（Cost阶段），检查自身是否可解放且是否具有用通常怪兽为素材融合召唤的标记，并执行解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:GetFlagEffect(id)>0 end
	-- 解放自身作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- 特殊召唤过滤条件：属于「元素英雄」系列、等级7以下、不能通常召唤、可以特殊召唤，且特殊召唤时对应的怪兽区域有空位
function s.spfilter(c,e,tp,rc)
	return c:IsSetCard(0x3008) and c:IsLevelBelow(7) and not c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若目标卡在卡组，则检查在解放这张卡后，主怪兽区是否有可用的空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,rc)>0
			-- 若目标卡在额外卡组，则检查在解放这张卡后，额外怪兽区或连接端是否有可用的空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0)
end
-- 效果②（特殊召唤「元素英雄」）的发动准备（Target阶段），检查卡组或额外卡组是否存在可特殊召唤的怪兽，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足过滤条件s.spfilter的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁处理的操作信息：从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- 效果②（特殊召唤「元素英雄」）的效果处理（Operation阶段），从卡组或额外卡组选择1只满足条件的怪兽无视召唤条件特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组及额外卡组中所有满足过滤条件s.spfilter的怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil,e,tp,e:GetHandler())
	if #g>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end
