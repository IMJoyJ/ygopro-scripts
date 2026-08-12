--アーティファクト－ヴァジュラ
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，这张卡特殊召唤成功的场合发动。自己的魔法与陷阱区域的卡全部破坏。
-- ④：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
function c69304426.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c69304426.spcon)
	e2:SetTarget(c69304426.sptg)
	e2:SetOperation(c69304426.spop)
	c:RegisterEffect(e2)
	-- ③：对方回合，这张卡特殊召唤成功的场合发动。自己的魔法与陷阱区域的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c69304426.descon)
	e3:SetTarget(c69304426.destg)
	e3:SetOperation(c69304426.desop)
	c:RegisterEffect(e3)
	-- ④：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69304426,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c69304426.hspcon)
	e4:SetTarget(c69304426.hsptg)
	e4:SetOperation(c69304426.hspop)
	c:RegisterEffect(e4)
end
-- 判断是否满足效果②的发动条件：在对方回合，此卡在魔法与陷阱区域盖放的状态下被破坏并送去墓地。
function c69304426.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断此卡是否因破坏而送去墓地，且当前回合玩家是对方。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动准备：此效果为必发效果，直接设置特殊召唤的操作信息。
function c69304426.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，对象为自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：若此卡仍存在于墓地，则将此卡特殊召唤。
function c69304426.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足效果③的发动条件：此卡特殊召唤成功时是否为对方回合。
function c69304426.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：筛选出位于魔法与陷阱区域前5格（即非场地区）的卡片。
function c69304426.filter(c)
	return c:GetSequence()<5
end
-- 效果③的发动准备：此效果为必发效果，获取自己魔法与陷阱区域的卡片并设置破坏的操作信息。
function c69304426.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己魔法与陷阱区域（不含场地区）的所有卡片。
	local g=Duel.GetMatchingGroup(c69304426.filter,tp,LOCATION_SZONE,0,nil)
	-- 设置破坏的操作信息，对象为获取到的卡片组，数量为该组的卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果③的效果处理：破坏自己魔法与陷阱区域的所有卡片。
function c69304426.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取自己魔法与陷阱区域（不含场地区）的所有卡片。
	local g=Duel.GetMatchingGroup(c69304426.filter,tp,LOCATION_SZONE,0,nil)
	-- 因效果破坏指定的卡片组。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断是否满足效果④的发动条件：对方怪兽进行直接攻击宣言时。
function c69304426.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果④的发动准备：检查自己场上是否有怪兽区域空位，以及此卡是否能特殊召唤，并设置特殊召唤的操作信息。
function c69304426.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，对象为自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果④的效果处理：若此卡仍在手卡，则将此卡特殊召唤。
function c69304426.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
