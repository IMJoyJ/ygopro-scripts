--Battle Royal Mode－Joining
-- 效果：
-- 以场上1只效果怪兽为对象才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽1回合最多2次不会被战斗破坏。作为对象的怪兽被战斗破坏时让造成破坏的玩家回复2000基本分。
-- ②：从回合玩家来看的对方玩家因战斗·效果受到伤害的场合发动。那个对方玩家可以让以下效果适用。
-- ●从手卡·卡组把1只4星以下的怪兽特殊召唤，失去2000基本分。
function c65433790.initial_effect(c)
	-- 以场上1只效果怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c65433790.target)
	e1:SetOperation(c65433790.tgop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，作为对象的怪兽1回合最多2次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2)
	e2:SetValue(c65433790.indct)
	c:RegisterEffect(e2)
	-- 作为对象的怪兽被战斗破坏时让造成破坏的玩家回复2000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c65433790.rccon)
	e3:SetOperation(c65433790.rcop)
	c:RegisterEffect(e3)
	-- ②：从回合玩家来看的对方玩家因战斗·效果受到伤害的场合发动。那个对方玩家可以让以下效果适用。●从手卡·卡组把1只4星以下的怪兽特殊召唤，失去2000基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65433790,0))  --"受到伤害的场合发动"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(c65433790.spcon)
	e4:SetOperation(c65433790.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的效果怪兽
function c65433790.filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 发动时的对象选择与合法性检查
function c65433790.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c65433790.filter(chkc) end
	-- 检查场上是否存在可以作为对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c65433790.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只表侧表示的效果怪兽作为对象并将其设为效果对象
	local g=Duel.SelectTarget(tp,c65433790.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 发动处理：将选择的怪兽设为这张卡的持续对象
function c65433790.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判定破坏原因是否为战斗
function c65433790.indct(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 检查作为对象的怪兽是否因战斗被破坏并送去墓地（或离场）
function c65433790.rccon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_BATTLE)
end
-- 让造成破坏的玩家回复2000基本分
function c65433790.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 给造成战斗破坏的玩家回复2000基本分
	Duel.Recover(tc:GetReasonPlayer(),2000,REASON_EFFECT)
end
-- 检查受到伤害的玩家是否为回合玩家的对方玩家
function c65433790.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定受到伤害的玩家（ep）不是当前的回合玩家
	return ep~=Duel.GetTurnPlayer()
end
-- 过滤条件：手卡或卡组中等级4以下的可以特殊召唤的怪兽
function c65433790.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：受到伤害的对方玩家可以选择从手卡或卡组特殊召唤1只4星以下怪兽并失去2000基本分
function c65433790.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查受到伤害的玩家场上是否有可用的怪兽区域
	if Duel.GetLocationCount(ep,LOCATION_MZONE)<=0 then return end
	-- 获取受到伤害的玩家手卡及卡组中满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(c65433790.spfilter,ep,LOCATION_HAND+LOCATION_DECK,0,nil,e,ep)
	-- 若存在可召唤的怪兽，询问受到伤害的玩家是否适用该效果
	if g:GetCount()>0 and Duel.SelectYesNo(ep,aux.Stringid(65433790,1)) then  --"是否特殊召唤？"
		-- 提示受到伤害的玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sc=g:Select(ep,1,1,nil)
		-- 将选择的怪兽以表侧表示特殊召唤到该玩家场上，若成功则执行后续处理
		if Duel.SpecialSummon(sc,0,ep,ep,false,false,POS_FACEUP)>0 then
			-- 使该玩家失去2000基本分
			Duel.SetLP(ep,Duel.GetLP(ep)-2000)
		end
	end
end
