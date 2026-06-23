--禁止令
-- 效果：
-- 宣言1个卡名才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，宣言的卡名为原本卡名的双方的卡受以下所适用（对从这个效果的适用前开始在场上存在的卡不适用）。
-- ●不能在场上出现。
-- ●不能作卡的发动以及效果的发动和适用。
-- ●不能通常召唤·反转召唤·特殊召唤。
-- ●不能作攻击以及表示形式的变更。
-- ●不能作为要为需要素材的特殊召唤而用的素材。
function c43711255.initial_effect(c)
	-- 创建一个永续魔法效果，用于处理禁止令的发动条件和效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c43711255.target)
	e1:SetOperation(c43711255.activate)
	c:RegisterEffect(e1)
end
-- 判断目标卡片是否为宣言的卡名的原本卡名且不在场上或在场上但为之后加入场上的卡
function c43711255.bantg(e,c)
	local fcode=e:GetLabel()
	return c:IsOriginalCodeRule(fcode) and (not c:IsOnField() or c:GetRealFieldID()>e:GetFieldID())
end
-- 处理禁止令的发动，提示玩家宣言一个卡名并设置目标参数
function c43711255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示“请宣言一个卡名”的选择消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家宣言一个卡牌编号
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡牌编号设置为连锁的目标参数
	Duel.SetTargetParam(ac)
	-- 设置连锁的操作信息，标记为宣言卡名的效果
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 激活禁止令效果，创建一个影响全场的禁止效果
function c43711255.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标参数，即玩家宣言的卡牌编号
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	c:SetHint(CHINT_CARD,ac)
	-- 创建一个影响全场的禁止效果，禁止宣言卡名的卡牌进行各种行为
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_FORBIDDEN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetTarget(c43711255.bantg)
	e2:SetLabel(ac)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 手动刷新场上受影响卡牌的状态，使禁止效果立即生效
	Duel.AdjustInstantly(c)
end
