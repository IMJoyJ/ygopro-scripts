--武神隠
-- 效果：
-- 选择自己场上1只名字带有「武神」的超量怪兽才能发动。选择的怪兽除外，场上的怪兽全部回到手卡。直到发动后第2次的自己的结束阶段时，双方不能召唤·反转召唤·特殊召唤，双方受到的全部伤害变成0。此外，发动后第2次的自己的结束阶段时发动。这张卡的效果除外的怪兽特殊召唤，选择自己墓地1只名字带有「武神」的怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。
function c11221418.initial_effect(c)
	-- 创建武神隐的发动效果，设置其为自由连锁、取对象效果，包含回手和除外的处理类别
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c11221418.target)
	e1:SetOperation(c11221418.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选自己场上满足条件的超量怪兽（名字带武神、正面表示、可除外、场上存在可回手怪兽）
function c11221418.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
		-- 检查场上是否存在至少一张可回手的怪兽，用于确认是否满足发动条件
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 目标选择函数，用于选择满足条件的怪兽作为效果对象
function c11221418.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11221418.filter(chkc) end
	-- 检查是否满足发动条件，即自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c11221418.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c11221418.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取所有可回手的怪兽组
	local tg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetFirst())
	-- 设置操作信息，将选择的怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息，将场上的怪兽全部回手
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,tg:GetCount(),0,0)
end
-- 发动处理函数，执行效果的主要处理逻辑
function c11221418.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且满足除外条件，若满足则将其除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		tc:RegisterFlagEffect(11221418,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 获取所有可回手的怪兽组
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 将场上的所有怪兽送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 计算发动后第2次自己的结束阶段的回合数
		local rct=Duel.GetTurnCount(tp)+1
		-- 若当前回合玩家不是发动者，则回合数加1
		if Duel.GetTurnPlayer()~=tp then rct=rct+1 end
		-- 创建并注册召唤限制效果，禁止双方在接下来的2个结束阶段内进行召唤、反转召唤和特殊召唤
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册召唤限制效果
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		e3:SetLabelObject(e2)
		-- 注册反转召唤限制效果
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e4:SetLabelObject(e3)
		-- 注册特殊召唤限制效果
		Duel.RegisterEffect(e4,tp)
		-- 创建并注册伤害相关效果，使双方受到的伤害变为0
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_CHANGE_DAMAGE)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetTargetRange(1,1)
		e5:SetValue(0)
		e5:SetLabelObject(e4)
		e5:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册伤害变更效果
		Duel.RegisterEffect(e5,tp)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e6:SetLabelObject(e5)
		e6:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册无效伤害效果
		Duel.RegisterEffect(e6,tp)
		-- 创建并注册结束阶段重置效果，用于在指定回合结束后重置所有限制效果
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(aux.Stringid(11221418,0))  --"结束召唤限制"
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_PHASE+PHASE_END)
		e7:SetCountLimit(1)
		e7:SetCondition(c11221418.resetcon)
		e7:SetOperation(c11221418.resetop)
		e7:SetLabel(rct)
		e7:SetLabelObject(e6)
		e7:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册结束阶段重置效果
		Duel.RegisterEffect(e7,tp)
		-- 创建并注册触发效果，用于在发动后第2次自己的结束阶段时特殊召唤除外的怪兽
		local e8=Effect.CreateEffect(c)
		e8:SetDescription(aux.Stringid(11221418,1))  --"这张卡的效果除外的怪兽特殊召唤"
		e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e8:SetCode(EVENT_PHASE+PHASE_END)
		e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e8:SetCountLimit(1)
		e8:SetCondition(c11221418.spcon)
		e8:SetTarget(c11221418.sptg)
		e8:SetOperation(c11221418.spop)
		e8:SetLabel(rct)
		e8:SetLabelObject(tc)
		e8:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册特殊召唤触发效果
		Duel.RegisterEffect(e8,tp)
	end
end
-- 结束阶段重置条件函数，判断是否到达指定回合
function c11221418.resetcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者且回合数匹配
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==Duel.GetTurnCount(tp)
end
-- 结束阶段重置处理函数，重置所有相关效果
function c11221418.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e6=e:GetLabelObject()
	local e5=e6:GetLabelObject()
	local e4=e5:GetLabelObject()
	local e3=e4:GetLabelObject()
	local e2=e3:GetLabelObject()
	e2:Reset()
	e3:Reset()
	e4:Reset()
	e5:Reset()
	e6:Reset()
	e:Reset()
end
-- 特殊召唤触发条件函数，判断是否到达指定回合
function c11221418.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者且回合数匹配
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==Duel.GetTurnCount(tp)
end
-- 过滤函数，用于筛选自己墓地满足条件的怪兽（名字带武神、怪兽类型、可叠放）
function c11221418.mfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 特殊召唤目标选择函数，选择墓地中的怪兽作为叠放对象
function c11221418.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11221418.mfilter(chkc) end
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	-- 提示玩家选择要作为超量素材的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择满足条件的墓地怪兽作为叠放对象
	local g=Duel.SelectTarget(tp,c11221418.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，将选择的墓地怪兽送入墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息，将除外的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 特殊召唤处理函数，执行特殊召唤和叠放操作
function c11221418.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前特殊召唤效果的目标怪兽
	local mc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足特殊召唤条件且成功特殊召唤
	if tc:GetFlagEffect(11221418)~=0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if mc and mc:IsRelateToEffect(e) and mc:IsCanOverlay() then
			-- 将选择的墓地怪兽叠放到特殊召唤的怪兽上
			Duel.Overlay(tc,Group.FromCards(mc))
		end
	end
end
