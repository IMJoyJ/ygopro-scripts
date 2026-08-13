--グラビティ・コントローラー
-- 效果：
-- 连接怪兽以外的额外怪兽区域的怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：额外怪兽区域的这张卡不会被和主要怪兽区域的怪兽的战斗破坏。
-- ②：这张卡和额外怪兽区域的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到卡组。
function c23656668.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设定连接召唤手续：可用1只“连接怪兽以外的额外怪兽区域的怪兽”作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,c23656668.mfilter,1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c23656668.lmlimit)
	c:RegisterEffect(e1)
	-- ①：额外怪兽区域的这张卡不会被和主要怪兽区域的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c23656668.indes)
	c:RegisterEffect(e2)
	-- ②：这张卡和额外怪兽区域的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23656668,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c23656668.tdcon)
	e3:SetTarget(c23656668.tdtg)
	e3:SetOperation(c23656668.tdop)
	c:RegisterEffect(e3)
end
-- 过滤连接素材：怪兽不是连接怪兽，且位于额外怪兽区域（格号>4），即满足召唤条件“连接怪兽以外的额外怪兽区域的怪兽”。
function c23656668.mfilter(c)
	return not c:IsLinkType(TYPE_LINK) and c:GetSequence()>4
end
-- 判断禁止作为连接素材的条件：这张卡是连接召唤出场，且出场回合为当前回合（即连接召唤的当回合）。
function c23656668.lmlimit(e)
	local c=e:GetHandler()
	-- 判断此卡是否为本回合通过连接召唤出场：召唤类型为连接召唤，且其移动到当前区域的回合等于当前回合数。
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetTurnID()==Duel.GetTurnCount()
end
-- 免疫战斗破坏的条件：这张卡位于额外怪兽区域，且战斗对象位于主要怪兽区域（序号<=4），符合“额外怪兽区域的这张卡不会被和主要怪兽区域的怪兽的战斗破坏”。
function c23656668.indes(e,c)
	return e:GetHandler():GetSequence()>4 and c:GetSequence()<=4
end
-- ②效果的发动条件：此卡与对方额外怪兽区域的怪兽进行战斗（战斗对象存在、属于对方、位于额外怪兽区域），并将战斗对象暂存。
function c23656668.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsControler(1-tp) and tc:GetSequence()>4
end
-- ②效果发动时的处理：检查此卡和战斗对象都能回到卡组，并设置回卡组的操作信息（将这张卡和对方怪兽作为对象，数量2）。
function c23656668.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if chk==0 then return tc and c:IsAbleToDeck() and tc:IsAbleToDeck() end
	local g=Group.FromCards(c,tc)
	-- 登记操作信息：本连锁效果将把g中的2张卡（这张卡和战斗对象）返回卡组，分类为CATEGORY_TODECK。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- ②效果处理：确认此卡仍关联本次战斗后，若对方怪兽仍关联战斗且仍在对方场上，将这张卡和那只对方怪兽返回持有者卡组并洗牌。
function c23656668.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not c:IsRelateToBattle() then return end
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		local g=Group.FromCards(c,tc)
		-- 将g中的两张卡返回持有者卡组并洗牌（因为是效果送回卡组）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
