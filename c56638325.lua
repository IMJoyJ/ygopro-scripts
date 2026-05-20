--星輝士 デルタテロス
-- 效果：
-- 4星怪兽×3
-- ①：只要持有超量素材的这张卡在怪兽区域存在，在自己把怪兽召唤·特殊召唤的成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡·卡组把1只「星骑士」怪兽特殊召唤。
function c56638325.initial_effect(c)
	-- 设置XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，在自己把怪兽召唤·特殊召唤的成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c56638325.limcon)
	e1:SetOperation(c56638325.limop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ①：只要持有超量素材的这张卡在怪兽区域存在，在自己把怪兽召唤·特殊召唤的成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(c56638325.limop2)
	c:RegisterEffect(e3)
	-- ②：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56638325,0))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c56638325.descost)
	e3:SetTarget(c56638325.destg)
	e3:SetOperation(c56638325.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡·卡组把1只「星骑士」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56638325,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c56638325.spcon)
	e4:SetTarget(c56638325.sptg)
	e4:SetOperation(c56638325.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：检查怪兽是否由自己召唤或特殊召唤
function c56638325.limfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 召唤·特殊召唤成功时封锁效果发动的条件判定：自身持有超量素材，且有自己召唤·特殊召唤的怪兽存在
function c56638325.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0 and eg:IsExists(c56638325.limfilter,1,nil,tp)
end
-- 召唤·特殊召唤成功时封锁效果发动的具体处理：若当前无连锁则直接限制连锁，若在连锁中则注册相关事件在连锁结束时限制
function c56638325.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否没有正在处理的连锁
	if Duel.GetCurrentChain()==0 then
		-- 限制连锁直到连锁结束，使得对方不能发动效果
		Duel.SetChainLimitTillChainEnd(c56638325.chainlm)
	-- 判定当前是否在连锁1处理完毕后
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(56638325,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- ①：只要持有超量素材的这张卡在怪兽区域存在，在自己把怪兽召唤·特殊召唤的成功时对方不能把魔法·陷阱·怪兽的效果发动。②：1回合1次，把这张卡1个超量素材取除，以场上1张卡为对象才能发动。那张卡破坏。③：这张卡从场上送去墓地的场合才能发动。从手卡·卡组把1只「星骑士」怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c56638325.resetop)
		-- 在全局注册用于在有新连锁发动时重置标记的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 在全局注册用于在效果处理被中断时重置标记的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标记并使重置效果自身失效
function c56638325.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(56638325)
	e:Reset()
end
-- 连锁结束时的处理：若自身仍有素材且标记存在，则在连锁结束时限制对方发动效果，并重置标记
function c56638325.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetOverlayCount()>0 and e:GetHandler():GetFlagEffect(56638325)~=0 then
		-- 限制连锁直到连锁结束，使得对方不能发动效果
		Duel.SetChainLimitTillChainEnd(c56638325.chainlm)
	end
	e:GetHandler():ResetFlagEffect(56638325)
end
-- 连锁限制函数：仅允许自己（非对方）发动效果
function c56638325.chainlm(e,rp,tp)
	return tp==rp
end
-- 破坏效果的消耗：取除这张卡的1个超量素材
function c56638325.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏效果的目标判定与选择：以场上1张卡为对象
function c56638325.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判定场上是否存在可以作为破坏对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：包含破坏分类，目标为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的具体处理：将作为对象的卡破坏
function c56638325.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件：这张卡从场上送去墓地
function c56638325.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：手卡·卡组中可以特殊召唤的「星骑士」怪兽
function c56638325.spfilter(c,e,tp)
	return c:IsSetCard(0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标判定：检查怪兽区域是否有空位，以及手卡·卡组中是否存在可特殊召唤的「星骑士」怪兽
function c56638325.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡或卡组中是否存在满足条件的「星骑士」怪兽
		and Duel.IsExistingMatchingCard(c56638325.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：包含特殊召唤分类，数量为1，范围为手卡和卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的具体处理：从手卡·卡组选择1只「星骑士」怪兽特殊召唤
function c56638325.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上若无可用怪兽区域空格则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组选择1只满足条件的「星骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c56638325.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
