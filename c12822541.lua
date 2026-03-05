--DDリリス
-- 效果：
-- 「DD 莉莉丝」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。
-- ●以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽加入手卡。
-- ●从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
function c12822541.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤·特殊召唤成功的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12822541)
	e1:SetTarget(c12822541.thtg)
	e1:SetOperation(c12822541.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为「DD」怪兽且可加入手牌
function c12822541.filter1(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数，用于判断是否为表侧表示的「DD」灵摆怪兽且可加入手牌
function c12822541.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果处理时的初始化函数，用于设置选择目标和操作信息
function c12822541.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12822541.filter1(chkc) end
	-- 检测自己墓地是否存在满足条件的「DD」怪兽
	local b1=Duel.IsExistingTarget(c12822541.filter1,tp,LOCATION_GRAVE,0,1,nil)
	-- 检测自己额外卡组是否存在满足条件的「DD」灵摆怪兽
	local b2=Duel.IsExistingMatchingCard(c12822541.filter2,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 当两个效果都可用时，让玩家选择发动哪个效果
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(12822541,0),aux.Stringid(12822541,1))  --"自己墓地1只「DD」怪兽加入手卡" / "自己额外卡组1只「DD」灵摆怪兽加入手卡"
	-- 当只有墓地效果可用时，让玩家选择发动墓地效果
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(12822541,0))  --"自己墓地1只「DD」怪兽加入手卡"
	-- 当只有额外卡组效果可用时，直接选择额外卡组效果
	else op=Duel.SelectOption(tp,aux.Stringid(12822541,1))+1 end  --"自己额外卡组1只「DD」灵摆怪兽加入手卡"
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 向玩家发送提示信息，提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 选择自己墓地满足条件的1只「DD」怪兽作为对象
		local g=Duel.SelectTarget(tp,c12822541.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息，表示将1张卡从墓地加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 设置操作信息，表示将1张卡从额外卡组加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 效果处理函数，用于执行选择的效果
function c12822541.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁中被选择的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	else
		-- 向玩家发送提示信息，提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从自己额外卡组选择1只满足条件的「DD」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c12822541.filter2,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 手动显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的灵摆怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
