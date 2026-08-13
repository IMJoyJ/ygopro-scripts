--バッテリーリサイクル
-- 效果：
-- ①：以自己墓地2只攻击力1500以下的雷族怪兽为对象才能发动。那些雷族怪兽加入手卡。
function c99995595.initial_effect(c)
	-- 对应效果原文：“①：以自己墓地2只攻击力1500以下的雷族怪兽为对象才能发动。那些雷族怪兽加入手卡。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99995595.target)
	e1:SetOperation(c99995595.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择的怪兽条件：自己墓地中攻击力1500以下、雷族且能被加入手卡的怪兽。
function c99995595.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
-- 效果处理时筛选仍与本效果关联且仍为雷族的对象怪兽。
function c99995595.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_THUNDER)
end
-- 发动时的目标选择流程：验证对象合法性、给玩家提示、选择2张符合条件的墓地雷族怪兽并设置回手牌操作信息。
function c99995595.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99995595.filter(chkc) end
	-- 发动时检查自己墓地是否存在至少2张满足条件的雷族怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99995595.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 选择对象前，向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地中选择2张符合条件的雷族怪兽作为效果对象，并将其设为连锁对象。
	local g=Duel.SelectTarget(tp,c99995595.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁的操作信息为“加入手牌”类别，对象为已选择的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：取得连锁对象，筛选仍有效的雷族怪兽，将其加入手牌并让对方确认。
function c99995595.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的效果对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c99995595.opfilter,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后的雷族怪兽加入其持有者的手牌，操作原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
