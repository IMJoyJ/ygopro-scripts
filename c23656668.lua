--グラビティ・コントローラー
-- 效果：
-- 连接怪兽以外的额外怪兽区域的怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：额外怪兽区域的这张卡不会被和主要怪兽区域的怪兽的战斗破坏。
-- ②：这张卡和额外怪兽区域的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到卡组。
function c23656668.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，使用满足条件的怪兽作为连接素材，最少1个，最多1个
	aux.AddLinkProcedure(c,c23656668.mfilter,1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c23656668.lmlimit)
	c:RegisterEffect(e1)
	-- 额外怪兽区域的这张卡不会被和主要怪兽区域的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c23656668.indes)
	c:RegisterEffect(e2)
	-- 这张卡和额外怪兽区域的对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到卡组。
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
-- 过滤函数，用于筛选额外怪兽区域且非连接怪兽的怪兽
function c23656668.mfilter(c)
	return not c:IsLinkType(TYPE_LINK) and c:GetSequence()>4
end
-- 判断函数，用于判断该卡是否在连接召唤的回合
function c23656668.lmlimit(e)
	local c=e:GetHandler()
	-- 判断该卡是否为连接召唤且在当前回合召唤
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetTurnID()==Duel.GetTurnCount()
end
-- 判断函数，用于判断该卡是否不会被战斗破坏
function c23656668.indes(e,c)
	return e:GetHandler():GetSequence()>4 and c:GetSequence()<=4
end
-- 条件函数，用于判断是否满足发动效果的条件
function c23656668.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsControler(1-tp) and tc:GetSequence()>4
end
-- 目标函数，用于设置效果发动时的目标
function c23656668.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if chk==0 then return tc and c:IsAbleToDeck() and tc:IsAbleToDeck() end
	local g=Group.FromCards(c,tc)
	-- 设置连锁操作信息，指定将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理函数，执行将卡送回卡组的操作
function c23656668.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not c:IsRelateToBattle() then return end
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		local g=Group.FromCards(c,tc)
		-- 将指定的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
