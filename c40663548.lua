--アロマージ－マジョラム
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己的植物族怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。那之后，自己回复500基本分。
-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：自己基本分回复的场合，以最多有自己场上的「芳香」怪兽数量的对方墓地的卡为对象发动。那些卡除外。
function c40663548.initial_effect(c)
	-- ①：自己的植物族怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。那之后，自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40663548,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,40663548)
	e1:SetCondition(c40663548.spcon)
	e1:SetTarget(c40663548.sptg)
	e1:SetOperation(c40663548.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c40663548.bdcon)
	-- 设置效果目标为场上所有植物族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己基本分回复的场合，以最多有自己场上的「芳香」怪兽数量的对方墓地的卡为对象发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40663548,1))  --"对方墓地的卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,40663549)
	e3:SetCondition(c40663548.rmcon)
	e3:SetTarget(c40663548.rmtg)
	e3:SetOperation(c40663548.rmop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为植物族且之前控制过该玩家的怪兽
function c40663548.cfilter(c,tp)
	return c:IsRace(RACE_PLANT) and c:IsPreviousControler(tp)
end
-- 判断是否有满足条件的植物族怪兽被战斗破坏
function c40663548.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c40663548.cfilter,1,nil,tp)
end
-- 设置特殊召唤和回复LP的处理信息
function c40663548.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置回复LP的处理信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 执行特殊召唤和回复LP的操作
function c40663548.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 使玩家回复500基本分
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
-- 判断玩家基本分是否高于对方
function c40663548.bdcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断玩家基本分是否高于对方
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 判断是否为玩家自身回复基本分
function c40663548.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤函数，用于判断是否为正面表示的芳香族怪兽
function c40663548.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- 设置除外对方墓地卡片的目标选择和处理信息
function c40663548.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 计算玩家场上正面表示的芳香族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c40663548.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择对方墓地的卡片作为除外对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
		-- 设置除外卡片的处理信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	end
end
-- 执行除外卡片的操作
function c40663548.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的卡片并过滤出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将卡片除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
