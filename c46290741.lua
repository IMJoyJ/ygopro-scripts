--城塞クジラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只水属性怪兽解放才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选1张「潜海奇袭」在自己场上盖放。
-- ③：1回合1次，只以自己场上的水属性怪兽1只为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
function c46290741.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把自己场上2只水属性怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46290741,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,46290741)
	e1:SetCost(c46290741.spcost)
	e1:SetTarget(c46290741.sptg)
	e1:SetOperation(c46290741.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组选1张「潜海奇袭」在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46290741,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c46290741.settg)
	e2:SetOperation(c46290741.setop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，只以自己场上的水属性怪兽1只为对象的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46290741,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c46290741.discon)
	e3:SetTarget(c46290741.distg)
	e3:SetOperation(c46290741.disop)
	c:RegisterEffect(e3)
end
-- 用于筛选场上或手牌中我方的水属性怪兽
function c46290741.rfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足解放2只水属性怪兽的条件，并选择符合条件的怪兽进行解放
function c46290741.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的怪兽组，仅包含水属性的怪兽
	local rg=Duel.GetReleaseGroup(tp):Filter(c46290741.rfilter,nil,tp)
	-- 在不执行选择的情况下判断是否有满足条件的2只怪兽组合可以被解放
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从符合条件的怪兽中选择恰好2只进行解放
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 使用代替解放次数的效果（如暗影敌托邦）
	aux.UseExtraReleaseCount(g,tp)
	-- 实际执行解放操作，将选中的怪兽从场上移除
	Duel.Release(g,REASON_COST)
end
-- 判断该卡是否可以被特殊召唤
function c46290741.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c46290741.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以正面表示的形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 用于筛选卡组中可盖放的「潜海奇袭」
function c46290741.filter(c)
	return c:IsCode(19089195) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 判断是否满足发动效果的条件，即场上有空位且卡组中有「潜海奇袭」
function c46290741.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认卡组中是否存在「潜海奇袭」
		and Duel.IsExistingMatchingCard(c46290741.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放操作
function c46290741.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有空位则不执行盖放
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张「潜海奇袭」
	local g=Duel.SelectMatchingCard(tp,c46290741.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡以盖放形式放置到场上
		Duel.SSet(tp,tc)
	end
end
-- 用于筛选自己场上的水属性怪兽
function c46290741.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp)
end
-- 判断是否满足发动效果的条件，即对方发动的效果针对了我方的水属性怪兽且该连锁可被无效
function c46290741.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认目标为1张卡且该卡为我方场上的水属性怪兽，同时该连锁可以被无效
	return tg and tg:GetCount()==1 and tg:IsExists(c46290741.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理信息，包括使发动无效和破坏目标
function c46290741.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理信息，表示将破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁无效并破坏目标卡
function c46290741.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果连锁有效且目标卡存在则进行破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
