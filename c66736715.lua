--彗聖の将－ワンモア・ザ・ナイト
-- 效果：
-- ←11 【灵摆】 11→
-- ①：自己把怪兽灵摆召唤的场合发动。这张卡回到卡组最上面或者最下面。
-- 【怪兽效果】
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从手卡把怪兽灵摆召唤。
local s,id,o=GetID()
-- 初始化函数，注册灵摆怪兽的基本属性、灵摆效果和怪兽效果
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己把怪兽灵摆召唤的场合发动。这张卡回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从手卡把怪兽灵摆召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCost(s.expcost)
	e2:SetTarget(s.exptg)
	e2:SetOperation(s.expop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检测是否为自己灵摆召唤成功的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 灵摆效果的发动条件：自己灵摆召唤怪兽成功
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 灵摆效果的发动准备：设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理：让玩家选择将这张卡回到卡组最上面或最下面
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 让玩家选择将卡片放入卡组最上方还是最下方
		local opt=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,1),SEQ_DECKTOP},  --"卡组最上面"
			{true,aux.Stringid(id,2),SEQ_DECKBOTTOM})  --"卡组最下面"
		-- 将这张卡送回卡组的指定位置（最上面或最下面）
		Duel.SendtoDeck(c,nil,opt,REASON_EFFECT)
	end
end
-- 怪兽效果的发动代价：确认手牌中的这张卡未被公开（即给对方观看）
function s.expcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 怪兽效果的发动准备：确认本回合是否尚未发动过该效果
function s.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否已经注册过该效果的Flag，确保同名卡效果一回合只能发动一次
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 怪兽效果的处理：为玩家注册一个本回合内追加一次从手卡灵摆召唤怪兽的效果，并设置Flag
function s.expop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以从手卡把怪兽灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))  --"使用「彗圣之将-翌夜之莫桑石骑士」的效果灵摆召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.pendvalue)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将追加灵摆召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个持续到回合结束的Flag，用于防止同名卡效果在同一回合内重复发动
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 限制追加的灵摆召唤只能从手卡进行
function s.pendvalue(e,c)
	return c:IsLocation(LOCATION_HAND)
end
