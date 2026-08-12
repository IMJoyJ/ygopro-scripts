--死を謳う魔瞳
-- 效果：
-- ①：这次决斗中，以下效果各适用。
-- ●自己不能把手卡的怪兽的效果发动。
-- ●自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ●自己怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「魔瞳」卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这次决斗中，以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabel(id)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「魔瞳」卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与合法性检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前决斗中是否尚未适用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- ①效果的发动处理函数，注册决斗中持续适用的三个效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●自己不能把手卡的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"「讴歌死亡的魔瞳」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	-- 注册限制自己发动手卡怪兽效果的全局效果
	Duel.RegisterEffect(e1,tp)
	-- ●自己怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	-- 注册使自己怪兽在同一次战斗阶段中最多可以向怪兽攻击2次的全局效果
	Duel.RegisterEffect(e2,tp)
	-- ●自己怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。②：把墓地的这张卡除外才能发动。从卡组把1张「魔瞳」卡加入手卡。那之后，选自己1张手卡回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.dcon)
	e3:SetValue(DOUBLE_DAMAGE)
	-- 注册使自己怪兽战斗伤害翻倍的全局效果
	Duel.RegisterEffect(e3,tp)
	-- 为玩家注册已适用该效果的标记，防止重复发动
	Duel.RegisterFlagEffect(tp,id,0,0,1)
end
-- 伤害翻倍效果的适用条件函数
function s.dcon(e)
	-- 检查是否存在攻击对象（即必须是和怪兽的战斗）
	return Duel.GetAttackTarget()
end
-- 限制发动的过滤函数，限制手卡怪兽效果的发动
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤卡组中「魔瞳」卡片的检索条件函数
function s.thfilter(c)
	return c:IsSetCard(0x1bb) and c:IsAbleToHand()
end
-- ②效果的发动准备与合法性检查函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「魔瞳」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁处理信息：从手卡将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②效果的发动处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「魔瞳」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的卡加入手卡，则进行后续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 洗切自身手卡
		Duel.ShuffleHand(tp)
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从手卡选择1张卡送回卡组
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续的送回卡组处理不与加入手卡同时进行
			Duel.BreakEffect()
			-- 将选中的手卡送回卡组最下面
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
