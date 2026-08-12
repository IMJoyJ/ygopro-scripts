--リブロマンサー・アフェクテッド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「书灵师」怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽回到持有者手卡，得到那只对方怪兽的控制权。以仪式怪兽以外的自己怪兽为对象把这张卡发动的场合，这个效果得到控制权的怪兽在结束阶段回到持有者手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以自己场上1只「书灵师」怪兽和对方场上1只怪兽为对象才能发动。那只自己怪兽回到持有者手卡，得到那只对方怪兽的控制权。以仪式怪兽以外的自己怪兽为对象把这张卡发动的场合，这个效果得到控制权的怪兽在结束阶段回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「书灵师」怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x17c)
end
-- 效果发动的对象选择与合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以作为对象的表侧表示「书灵师」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以改变控制权的怪兽
		and Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只表侧表示的「书灵师」怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置将选择的自己怪兽送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
	-- 设置得到选择的对方怪兽控制权的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,1,0,0)
end
-- 效果处理的执行函数，处理回手牌、转移控制权以及非仪式怪兽时的结束阶段回手牌延迟效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local tg=Duel.GetTargetsRelateToChain()
	local hc=e:GetLabelObject()
	if hc and hc:IsControler(tp) and hc:IsRelateToEffect(e)
		-- 将作为对象的自己怪兽送回手牌，并确认其已成功回到手牌
		and Duel.SendtoHand(hc,nil,REASON_EFFECT)>0 and hc:IsLocation(LOCATION_HAND) then
		local tc=(tg-hc):GetFirst()
		if tc and tc:IsControler(1-tp) and tc:IsRelateToEffect(e)
			-- 成功得到对方怪兽的控制权，并判断作为对象的自己怪兽是否不是仪式怪兽
			and Duel.GetControl(tc,tp)>0 and not hc:IsType(TYPE_RITUAL) then
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 这个效果得到控制权的怪兽在结束阶段回到持有者手卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabelObject(tc)
			e1:SetLabel(fid)
			e1:SetCondition(s.thcon)
			e1:SetOperation(s.thop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册在结束阶段将控制权转移怪兽送回持有者手牌的全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 结束阶段回手牌效果的条件判断函数，检查卡片标记是否匹配，若不匹配则重置效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段回手牌效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将得到控制权的怪兽送回持有者手牌
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
