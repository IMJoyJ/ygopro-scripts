--スクイブ・ドロー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「弹丸」怪兽为对象才能发动。那只怪兽破坏，自己从卡组抽2张。
function c54458867.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「弹丸」怪兽为对象才能发动。那只怪兽破坏，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54458867+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c54458867.target)
	e1:SetOperation(c54458867.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「弹丸」怪兽
function c54458867.ddfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x102)
end
-- 效果发动时的对象选择与可行性检查
function c54458867.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c54458867.ddfilter(chkc) end
	-- 检查当前玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己场上是否存在可以作为对象的表侧表示「弹丸」怪兽
		and Duel.IsExistingTarget(c54458867.ddfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的「弹丸」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54458867.ddfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的对象玩家为当前玩家（用于抽卡效果）
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2（用于抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息：包含破坏1张所选卡的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁的操作信息：包含玩家抽2张卡的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理的执行函数
function c54458867.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组、对象玩家以及对象参数
	local g,p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检查对象卡片是否存在，并将其因效果破坏，若成功破坏则继续处理
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 让目标玩家因效果从卡组抽指定数量的卡
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
