--サイキック・ブロッカー
-- 效果：
-- ①：1回合1次，宣言1个卡名才能发动。直到对方回合结束时，宣言的卡名为原本卡名的双方的卡受以下所适用。
-- ●不能在场上出现。
-- ●不能作卡的发动以及效果的发动和适用。
-- ●不能通常召唤·反转召唤·特殊召唤。
-- ●不能作攻击以及表示形式的变更。
-- ●不能作为要为需要素材的特殊召唤而用的素材。
function c29417188.initial_effect(c)
	-- 效果原文内容：①：1回合1次，宣言1个卡名才能发动。直到对方回合结束时，宣言的卡名为原本卡名的双方的卡受以下所适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29417188,0))  --"宣言禁止"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c29417188.target)
	e1:SetOperation(c29417188.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置效果目标，提示玩家宣言卡名
function c29417188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：向玩家提示“请宣言一个卡名”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 效果作用：让玩家宣言一张卡片的卡号
	local ac=Duel.AnnounceCard(tp)
	-- 效果作用：将宣言的卡号设置为连锁的目标参数
	Duel.SetTargetParam(ac)
	-- 效果作用：设置连锁的操作信息，标记为宣言卡名的效果
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果作用：处理效果发动后的操作，设置禁止效果并注册
function c29417188.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中目标参数，即玩家宣言的卡号
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:GetHandler():SetHint(CHINT_CARD,ac)
	-- 效果原文内容：●不能在场上出现。●不能作卡的发动以及效果的发动和适用。●不能通常召唤·反转召唤·特殊召唤。●不能作攻击以及表示形式的变更。●不能作为要为需要素材的特殊召唤而用的素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_FORBIDDEN)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(c29417188.bantg)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 效果作用：将创建的禁止效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：判断目标卡片是否为宣言的卡号对应的原始卡
function c29417188.bantg(e,c)
	local fcode=e:GetLabel()
	return c:IsOriginalCodeRule(fcode)
end
