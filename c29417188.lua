--サイキック・ブロッカー
-- 效果：
-- ①：1回合1次，宣言1个卡名才能发动。直到对方回合结束时，宣言的卡名为原本卡名的双方的卡受以下所适用。
-- ●不能在场上出现。
-- ●不能作卡的发动以及效果的发动和适用。
-- ●不能通常召唤·反转召唤·特殊召唤。
-- ●不能作攻击以及表示形式的变更。
-- ●不能作为要为需要素材的特殊召唤而用的素材。
function c29417188.initial_effect(c)
	-- ①：1回合1次，宣言1个卡名才能发动。直到对方回合结束时为止的期间，宣言的卡名为原本卡名的双方的卡受以下所适用。●不能在场上出现。●不能作卡的发动以及效果的发动和适用。●不能通常召唤·反转召唤·特殊召唤。●不能作攻击以及表示形式的变更。●不能作为要为需要素材的特殊召唤而用的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29417188,0))  --"宣言禁止"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c29417188.target)
	e1:SetOperation(c29417188.operation)
	c:RegisterEffect(e1)
end
-- 发动时的条件判定与宣言处理：满足发动条件后，提示玩家宣言1个卡名，将宣言的卡号写入连锁参数，并标记本连锁为‘宣言卡名’类效果。
function c29417188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向操作玩家tp显示‘请宣言一个卡名’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家tp宣言1个卡名（不限卡种），并返回所宣言卡的卡号存入变量ac。
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡号ac设为当前连锁的目标参数，供后续效果处理时获取。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为CATEGORY_ANNOUNCE，表示本效果发动时需要宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理时：读取宣言的卡号，在发动者卡上记录提示信息，并给自己场上刷一个新的领域效果，该效果持续到对方回合结束，限制宣言卡名的原本卡名卡片。
function c29417188.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取宣言卡名时保存的目标参数ac。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:GetHandler():SetHint(CHINT_CARD,ac)
	-- ●不能在场上出现。●不能作卡的发动以及效果的发动和适用。●不能通常召唤·反转召唤·特殊召唤。●不能作攻击以及表示形式的变更。●不能作为要为需要素材的特殊召唤而用的素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_FORBIDDEN)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(c29417188.bantg)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将新建的领域效果e1注册到决斗中（由tp控制），使其开始生效持续至对方回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- EFFECT_FORBIDDEN的适用判定：若卡片c的原本卡名等于e1保存的宣言卡号，则c受到禁止状态限制。
function c29417188.bantg(e,c)
	local fcode=e:GetLabel()
	return c:IsOriginalCodeRule(fcode)
end
