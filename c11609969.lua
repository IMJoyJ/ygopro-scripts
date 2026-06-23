--DD魔導賢者ケプラー
-- 效果：
-- ←10 【灵摆】 10→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：自己准备阶段发动。这张卡的灵摆刻度下降2（最少到1）。那之后，持有这张卡的灵摆刻度数值以上的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●以自己场上1张其他的「DD」卡为对象才能发动。那张卡回到手卡。
-- ●从卡组把1张「契约书」卡加入手卡。
function c11609969.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c11609969.splimit)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。这张卡的灵摆刻度下降2（最少到1）。那之后，持有这张卡的灵摆刻度数值以上的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c11609969.sccon)
	e3:SetTarget(c11609969.sctg)
	e3:SetOperation(c11609969.scop)
	c:RegisterEffect(e3)
	-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。●以自己场上1张其他的「DD」卡为对象才能发动。那张卡回到手卡。●从卡组把1张「契约书」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,11609969)
	e4:SetTarget(c11609969.thtg)
	e4:SetOperation(c11609969.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 判断是否为非DD怪兽且为灵摆召唤
function c11609969.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xaf) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断是否为准备阶段
function c11609969.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤满足等级条件的怪兽
function c11609969.filter(c,lv)
	return c:IsFaceup() and not c:IsSetCard(0xaf) and c:IsLevelAbove(lv)
end
-- 设置连锁处理时的破坏效果目标
function c11609969.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local scl=math.max(1,e:GetHandler():GetLeftScale()-2)
	-- 获取满足等级条件的场上怪兽数组
	local g=Duel.GetMatchingGroup(c11609969.filter,tp,LOCATION_MZONE,0,nil,scl)
	if e:GetHandler():GetLeftScale()>1 then
		-- 设置连锁操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 处理灵摆刻度下降和破坏效果
function c11609969.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()==1 then return end
	local scl=2
	if c:GetLeftScale()==2 then scl=1 end
	-- 设置灵摆刻度下降效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(-scl)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
	-- 获取满足等级条件的场上怪兽数组
	local g=Duel.GetMatchingGroup(c11609969.filter,tp,LOCATION_MZONE,0,nil,c:GetLeftScale())
	if g:GetCount()>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将目标怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤场上的DD怪兽
function c11609969.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsAbleToHand()
end
-- 过滤契约书卡
function c11609969.filter2(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end
-- 设置怪兽效果发动时的选择处理
function c11609969.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c11609969.filter1(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在DD怪兽
	local b1=Duel.IsExistingTarget(c11609969.filter1,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
	-- 检查卡组是否存在契约书卡
	local b2=Duel.IsExistingMatchingCard(c11609969.filter2,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 若两个选项都存在，则选择其中一个
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(11609969,0),aux.Stringid(11609969,1))  --"自己场上1张「DD」卡回到手卡" / "自己卡组1张「契约书」卡加入手卡"
	-- 若只有DD怪兽选项存在，则选择该选项
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(11609969,0))  --"自己场上1张「DD」卡回到手卡"
	-- 若只有契约书卡选项存在，则选择该选项
	else op=Duel.SelectOption(tp,aux.Stringid(11609969,1))+1 end  --"自己卡组1张「契约书」卡加入手卡"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 提示选择目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		-- 选择目标DD怪兽
		local g=Duel.SelectTarget(tp,c11609969.filter1,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
		-- 设置连锁操作信息为送入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
		-- 设置连锁操作信息为从卡组检索
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 处理怪兽效果发动后的选择效果
function c11609969.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽送入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认目标怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	else
		-- 提示选择目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从卡组选择契约书卡
		local g=Duel.SelectMatchingCard(tp,c11609969.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将契约书卡送入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认契约书卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
