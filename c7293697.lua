--完全なる世界 トゥーン・ワールド
local s,id,o=GetID()
-- 初始化效果函数，注册场地卡的激活和发动效果
function s.initial_effect(c)
	-- 将此卡在场地区变更为卡号为15259703的卡
	aux.EnableChangeCode(c,15259703,LOCATION_FZONE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 发动效果：检索满足条件的卡加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 连锁处理时点触发的效果，用于除外TOON怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 检索过滤器函数，判断是否为TOON系列或相关卡
function s.thfilter(c)
	-- 判断卡片是否为TOON系列、记述了TOON系列怪兽或为特定卡
	return (c:IsSetCard(0x62) or aux.IsSetNameMonsterListed(c,0x62) or aux.IsCodeListed(c,15259703))
		and c:IsAbleToHand()
end
-- 效果发动的条件判断函数，检查是否有满足条件的卡且未超过使用次数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足检索条件的卡且玩家未使用过此效果3次
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)<3 end
	-- 注册一个标识效果，记录此效果已使用过1次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，提示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的操作函数，选择并检索卡牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断连锁处理时是否满足除外TOON怪兽的条件
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
		-- 检查场上是否存在满足条件的TOON怪兽
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 除外TOON怪兽的过滤器函数，判断是否为表侧表示且可除外的TOON怪兽
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and c:IsType(TYPE_TOON)
end
-- 效果发动时的操作函数，选择并除外TOON怪兽
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的TOON怪兽
		local tg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 显示发动动画提示
		Duel.Hint(HINT_CARD,0,id)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(tg)
		local rc=tg:GetFirst()
		-- 将选中的怪兽以临时除外方式移除
		if Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			-- 注册连锁解决时触发的效果，用于将除外的怪兽返回场上
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(rc)
			e1:SetCountLimit(1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 将效果e1注册到玩家
			Duel.RegisterEffect(e1,tp)
			-- 注册禁止除外效果，防止该卡被再次除外
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_REMOVE)
			e2:SetTargetRange(1,0)
			e2:SetTarget(s.rmlimit)
			e2:SetLabel(rc:GetOriginalCode())
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将效果e2注册到玩家
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制除外效果的条件函数，判断是否为特定卡且因效果被除外
function s.rmlimit(e,c,tp,r,re)
	return c:GetOriginalCode()==e:GetLabel() and re and re:GetHandler():GetOriginalCode()==id and r&REASON_EFFECT~=0
end
-- 返回场上的条件判断函数，判断是否为已标记的怪兽
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 将标记的怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标记的怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
