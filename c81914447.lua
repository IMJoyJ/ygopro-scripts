--No－P.U.N.K.オーガ・ナンバー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「朋克」怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：把手卡·场上的这张卡送去墓地才能发动。从卡组把1只8星以外的「朋克」怪兽加入手卡。
-- ③：1回合1次，对方把怪兽的效果发动时才能发动。这张卡的攻击力直到回合结束时上升那只对方怪兽的原本攻击力数值。
function c81914447.initial_effect(c)
	-- ①：把自己场上1只「朋克」怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81914447,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81914447)
	e1:SetCost(c81914447.spcost)
	e1:SetTarget(c81914447.sptg)
	e1:SetOperation(c81914447.spop)
	c:RegisterEffect(e1)
	-- ②：把手卡·场上的这张卡送去墓地才能发动。从卡组把1只8星以外的「朋克」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81914447,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,81914448)
	e2:SetCost(c81914447.thcost)
	e2:SetTarget(c81914447.thtg)
	e2:SetOperation(c81914447.thop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽的效果发动时才能发动。这张卡的攻击力直到回合结束时上升那只对方怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81914447,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c81914447.atkcon)
	e3:SetOperation(c81914447.atkop)
	c:RegisterEffect(e3)
end
-- 过滤满足解放条件的「朋克」怪兽（需保证解放后有可用的怪兽区域，且为自己场上的怪兽或自己场上表侧表示的怪兽）
function c81914447.spfilter(c,tp)
	-- 检查该卡解放后是否能空出至少1个怪兽区域，且该卡是「朋克」怪兽，并且是自己控制的卡或表侧表示的卡
	return Duel.GetMZoneCount(tp,c)>0 and c:IsSetCard(0x171) and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤效果的Cost（代价）处理函数：检查并解放自己场上1只「朋克」怪兽
function c81914447.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c81914447.spfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c81914447.spfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的Target（目标）处理函数：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c81914447.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的Operation（效果处理）函数：将自身特殊召唤
function c81914447.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动者的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索效果的Cost（代价）处理函数：检查并把手卡·场上的这张卡送去墓地
function c81914447.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中8星以外的「朋克」怪兽
function c81914447.thfilter(c)
	return c:IsSetCard(0x171) and c:IsType(TYPE_MONSTER) and not c:IsLevel(8) and c:IsAbleToHand()
end
-- 检索效果的Target（目标）处理函数：检查卡组中是否存在满足条件的怪兽，并设置加入手卡的操作信息
function c81914447.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81914447.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation（效果处理）函数：从卡组选择1只8星以外的「朋克」怪兽加入手卡
function c81914447.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81914447.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升效果的Condition（发动条件）函数：对方把怪兽的效果发动时
function c81914447.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
end
-- 攻击力上升效果的Operation（效果处理）函数：获取对方发动效果的怪兽的原本攻击力，并使这张卡的攻击力直到回合结束时上升该数值
function c81914447.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=0
		if rc:IsRelateToEffect(re) and (rc:IsFaceup() or not rc:IsLocation(LOCATION_MZONE)) then
			if rc:IsControler(1-tp) then
				atk=rc:GetBaseAttack()
			end
		else
			atk=rc:GetTextAttack()
		end
		if atk>0 then
			-- 这张卡的攻击力直到回合结束时上升那只对方怪兽的原本攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
