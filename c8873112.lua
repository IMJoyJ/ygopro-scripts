--アーティファクト－チャクラム
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：要让自己场上的魔法·陷阱卡破坏的效果发动时，让自己场上盖放的1张魔法·陷阱卡回到持有者手卡才能发动。这张卡从手卡特殊召唤。
function c8873112.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8873112,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c8873112.spcon)
	e2:SetTarget(c8873112.sptg)
	e2:SetOperation(c8873112.spop)
	c:RegisterEffect(e2)
	-- ③：要让自己场上的魔法·陷阱卡破坏的效果发动时，让自己场上盖放的1张魔法·陷阱卡回到持有者手卡才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8873112,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c8873112.spcon2)
	e3:SetCost(c8873112.spcost)
	e3:SetTarget(c8873112.sptg2)
	e3:SetOperation(c8873112.spop)
	c:RegisterEffect(e3)
end
-- 判断特殊召唤效果的发动条件：此卡之前是否在自己的魔陷区盖放，且在对方回合被破坏送去墓地
function c8873112.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断此卡是否因破坏送去墓地，且当前回合玩家不是自己（即对方回合）
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的发动准备：必发效果，直接返回true并设置特殊召唤的操作信息
function c8873112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的具体执行：若此卡仍存在于墓地，则将其特殊召唤
function c8873112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：自己场上的魔法·陷阱卡
function c8873112.cfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断手卡特殊召唤效果的发动条件：检测当前发动的效果是否包含破坏自己场上魔法·陷阱卡的操作
function c8873112.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关于破坏操作的信息（是否包含破坏、破坏的对象、破坏的数量）
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c8873112.cfilter,nil,tp)-tg:GetCount()>0
end
-- 过滤条件：自己场上盖放的且能返回手牌的魔法·陷阱卡
function c8873112.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHandAsCost()
end
-- 手卡特殊召唤效果的代价处理：让自己场上盖放的1张魔法·陷阱卡回到持有者手卡
function c8873112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查自己场上是否存在至少1张可以返回手牌的盖放魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8873112.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 向玩家发送提示信息：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1张自己场上盖放的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c8873112.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为代价送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 手卡特殊召唤效果的靶向处理：检查怪兽区域空位及自身是否能特殊召唤，并设置操作信息
function c8873112.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：将手卡中的此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
