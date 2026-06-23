--マジェスペクター・ユニコーン
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己·对方回合，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
function c31178212.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己·对方回合，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31178212)
	e2:SetTarget(c31178212.thtg)
	e2:SetOperation(c31178212.thop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为aux.tgoval函数，用于判断该卡是否不会成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.indoval函数，用于判断该卡是否不会被对方效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
end
-- 过滤函数：选择场上正面表示的灵摆怪兽，且可以送入手牌
function c31178212.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果处理前的检查函数，判断是否满足发动条件
function c31178212.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只正面表示的灵摆怪兽
	if chk==0 then return Duel.IsExistingTarget(c31178212.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可以送入手牌的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只正面表示的灵摆怪兽作为目标
	local g1=Duel.SelectTarget(tp,c31178212.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只可以送入手牌的怪兽作为目标
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息，表示将要处理的卡为2张，分类为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理函数，将符合条件的目标怪兽送入手牌
function c31178212.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡组，并筛选出与该效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡送入手牌，原因使用效果
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
