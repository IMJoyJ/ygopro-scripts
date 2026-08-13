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
	-- 宣言1个卡名才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c43711255.target)
	e1:SetOperation(c43711255.activate)
	c:RegisterEffect(e1)
end
-- 判断目标卡是否为宣言的原本卡名，且该卡不在场上或是在本效果发动之后才出现在场上（即排除效果适用前已在场上存在的卡）。
function c43711255.bantg(e,c)
	local fcode=e:GetLabel()
	return c:IsOriginalCodeRule(fcode) and (not c:IsOnField() or c:GetRealFieldID()>e:GetFieldID())
end
-- 禁止令发动时的目标处理：确认可以发动后，提示玩家宣言一个卡名，并将宣言卡号记录为连锁目标参数，同时设置操作信息为卡名宣言类效果。
function c43711255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向发动玩家弹出宣言卡名的选择框，提示内容为“请宣言一个卡名”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让发动玩家宣言一个卡名（卡号），将宣言结果存入变量ac。
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡号写入当前连锁的目标参数，以便效果处理阶段获取。
	Duel.SetTargetParam(ac)
	-- 声明本次连锁的操作种类为“宣言卡名”（CATEGORY_ANNOUNCE），用于给其他卡片的判定提供操作信息（例如能否连锁等）。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 禁止令发动成功后的效果处理：读取连锁中记录的宣言卡号；以禁止令自身为来源创建一个永续的场上的禁止效果（EFFECT_FORBIDDEN），作用于双方所有区域中原本卡名为宣言卡名的卡，并立即刷新状态。
function c43711255.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出发动时记录的宣言卡号，存入变量ac。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	c:SetHint(CHINT_CARD,ac)
	-- ①：只要这张卡在魔法与陷阱区域存在，宣言的卡名为原本卡名的双方的卡受以下所适用（对从这个效果的适用前开始在场上存在的卡不适用）。●不能在场上出现。●不能作卡的发动以及效果的发动和适用。●不能通常召唤·反转召唤·特殊召唤。●不能作攻击以及表示形式的变更。●不能作为要为需要素材的特殊召唤而用的素材。
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
	-- 立即执行一次状态刷新，使禁止令的永续效果即刻生效（包括正确排除效果适用前已在场上存在的同名卡）。
	Duel.AdjustInstantly(c)
end
