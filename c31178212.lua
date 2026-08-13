--マジェスペクター・ユニコーン
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己·对方回合，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
function c31178212.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（对应‘←2 【灵摆】 2→’），使其可以作为灵摆卡发动并进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 【怪兽效果】这个卡名的①的怪兽效果1回合只能使用1次。①：自己·对方回合，以自己场上1只灵摆怪兽和对方场上1只怪兽为对象才能发动。那些怪兽回到手卡。
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
	-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 将‘不能成为效果对象’的判定函数设置为aux.tgoval，使这张卡不会成为对方卡的效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	-- 将‘不会被效果破坏’的判定函数设置为aux.indoval，使这张卡不会被对方的效果破坏。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
end
-- 筛选条件：对象须为表侧表示、是灵摆怪兽且能够加入手卡。
function c31178212.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果的目标选择函数：由于需要同时选择两个对象，不对单卡chkc做合法性校验（chkc存在时返回false）；在chk==0时检查自己场上是否有1只符合条件的灵摆怪兽且对方场上是否有1只能够加入手卡的怪兽，作为发动条件。
function c31178212.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只符合条件的、能成为效果对象的灵摆怪兽（表侧表示且能加入手卡），作为发动条件之一。
	if chk==0 then return Duel.IsExistingTarget(c31178212.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只能够加入手卡且能成为效果对象的怪兽，作为另一个发动条件。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家发送‘请选择要返回手卡的牌’的提示，用于选择自己场上的灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让当前玩家从自己场上选择1只符合条件的灵摆怪兽作为对象，并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c31178212.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次向当前玩家发送‘请选择要返回手卡的牌’的提示，用于选择对方场上的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让当前玩家从对方场上选择1只能够加入手卡的怪兽作为对象，并登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置当前连锁的操作信息：该效果涉及返回手卡，对象为已选择的2张卡，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理函数：从当前连锁信息中取得对象卡，筛选出仍与本效果相关的卡，然后将它们返回持有者的手卡。
function c31178212.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取所有对象卡，并筛选出仍然与本效果相关的卡（如仍处于可处理状态且未离场）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因将筛选出的卡返回各卡的持有者的手卡（nil表示返回原持有者的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
