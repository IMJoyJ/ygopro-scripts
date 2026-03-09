--エンタメ・バンド・ハリケーン
-- 效果：
-- 「娱乐乐队飓风」在1回合只能发动1张。
-- ①：以最多有自己场上的「娱乐伙伴」怪兽数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
function c46066477.initial_effect(c)
	-- 效果原文内容：「娱乐乐队飓风」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,46066477+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46066477.target)
	e1:SetOperation(c46066477.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤自己场上表侧表示的「娱乐伙伴」怪兽
function c46066477.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 效果作用：检查是否满足发动条件，即自己场上存在「娱乐伙伴」怪兽且对方场上有可返回手牌的卡
function c46066477.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 效果作用：检查自己场上是否存在至少1只「娱乐伙伴」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46066477.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查对方场上是否存在至少1张可返回手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 效果作用：计算自己场上「娱乐伙伴」怪兽数量作为最大选择数量
	local ct=Duel.GetMatchingGroupCount(c46066477.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果作用：选择最多等于「娱乐伙伴」怪兽数量的对方场上的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 效果作用：设置连锁操作信息，指定将选中的卡送入持有者手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果原文内容：①：以最多有自己场上的「娱乐伙伴」怪兽数量的对方场上的卡为对象才能发动。那些卡回到持有者手卡。
function c46066477.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中选定的对象卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 效果作用：将符合条件的卡送入持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
