--トリックスターバンド・ギタースイート
-- 效果：
-- 「淘气仙星」连接怪兽＋「淘气仙星」怪兽
-- ①：和这张卡连接状态的自己的「淘气仙星」连接怪兽的效果给与对方的伤害变成2倍。
-- ②：每次「淘气仙星」怪兽的效果让对方受到伤害发动。这张卡的攻击力上升那次伤害的数值。
-- ③：这张卡攻击的回合的结束阶段发动。这张卡的②的效果上升的数值回到0。那之后，可以从自己墓地选1只「淘气仙星」怪兽加入手卡。
function c91272072.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，素材为1只「淘气仙星」怪兽和1只满足过滤条件的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xfb),c91272072.matfilter,true)
	-- ①：和这张卡连接状态的自己的「淘气仙星」连接怪兽的效果给与对方的伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c91272072.damval)
	c:RegisterEffect(e1)
	-- ②：每次「淘气仙星」怪兽的效果让对方受到伤害发动。这张卡的攻击力上升那次伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91272072,0))  --"上升攻击力"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c91272072.atkcon)
	e2:SetOperation(c91272072.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的回合的结束阶段发动。这张卡的②的效果上升的数值回到0。那之后，可以从自己墓地选1只「淘气仙星」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91272072,1))  --"攻击力恢复"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetLabelObject(e2)
	e3:SetCondition(c91272072.condition)
	e3:SetTarget(c91272072.target)
	e3:SetOperation(c91272072.operation)
	c:RegisterEffect(e3)
end
-- 过滤融合素材：属于「淘气仙星」系列的连接怪兽
function c91272072.matfilter(c)
	return c:IsFusionType(TYPE_LINK) and c:IsFusionSetCard(0xfb)
end
-- 判断伤害是否由与自身处于连接状态的自己的「淘气仙星」连接怪兽的效果造成，若是则伤害变成2倍
function c91272072.damval(e,re,val,r,rp)
	if r&REASON_EFFECT==REASON_EFFECT and re and re:IsActiveType(TYPE_MONSTER) then
		local rc=re:GetHandler()
		if rc:IsFaceup() and rc:IsSetCard(0xfb) and rc:IsType(TYPE_LINK)
			and rc:GetLinkedGroup():IsContains(e:GetHandler()) then
			return val*2
		end
	end
	return val
end
-- 判断是否为对方因「淘气仙星」怪兽的效果受到伤害，作为攻击力上升效果的发动条件
function c91272072.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r&REASON_EFFECT==REASON_EFFECT and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 执行攻击力上升效果，使这张卡的攻击力上升那次伤害的数值
function c91272072.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那次伤害的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetLabelObject(e)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤可以加入手卡的墓地中的「淘气仙星」怪兽
function c91272072.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- 判断这张卡在当前回合是否进行过攻击，作为结束阶段效果的发动条件
function c91272072.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 结束阶段效果的靶向处理，声明将墓地的卡加入手卡的操作信息
function c91272072.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为从自己墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 执行结束阶段效果：重置由效果②上升的攻击力数值，之后可以从自己墓地选1只「淘气仙星」怪兽加入手卡
function c91272072.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local chk=false
		local effs={c:IsHasEffect(EFFECT_UPDATE_ATTACK)}
		for _,eff in ipairs(effs) do
			if eff:GetLabelObject()==e:GetLabelObject() then
				eff:Reset()
				chk=true
			end
		end
		-- 获取自己墓地中不受「王家之谷」影响且满足条件的「淘气仙星」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c91272072.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若成功重置了攻击力且墓地有符合条件的怪兽，则询问玩家是否将怪兽加入手卡
		if chk and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(91272072,2)) then  --"是否从自己墓地选1只「淘气仙星」怪兽加入手卡？"
			-- 中断当前效果处理，使后续的加入手卡处理不与重置攻击力同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡因效果加入玩家手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
