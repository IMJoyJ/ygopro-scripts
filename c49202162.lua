--混沌の戦士 カオス・ソルジャー
-- 效果：
-- 卡名不同的怪兽3只
-- ①：这张卡是已用7星以上的怪兽为素材作连接召唤的场合，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：这张卡战斗破坏对方怪兽时，可以从以下效果选择1个发动。
-- ●这张卡的攻击力上升1500。
-- ●这张卡在下次的自己回合的战斗阶段中可以作2次攻击。
-- ●场上1张卡除外。
function c49202162.initial_effect(c)
	-- 添加连接召唤手续，要求使用3只以上卡名不同的怪兽作为素材
	aux.AddLinkProcedure(c,nil,3,3,c49202162.lcheck)
	c:EnableReviveLimit()
	-- 这张卡是已用7星以上的怪兽为素材作连接召唤的场合，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c49202162.regcon)
	e1:SetOperation(c49202162.regop)
	c:RegisterEffect(e1)
	-- 检查连接召唤使用的素材中是否存在7星以上的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49202162.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c49202162.tgcon)
	-- 设置该效果为不会被无效
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这张卡不会被对方的效果破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c49202162.tgcon)
	-- 设置该效果为不会被无效
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- 战斗破坏对方怪兽时，可以从以下效果选择1个发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(49202162,0))  --"选择效果发动"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否与对方怪兽战斗且该怪兽被战斗破坏
	e5:SetCondition(aux.bdocon)
	e5:SetTarget(c49202162.efftg)
	e5:SetOperation(c49202162.effop)
	c:RegisterEffect(e5)
end
-- 连接召唤素材的卡名不能重复
function c49202162.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 判断是否为连接召唤且满足7星以上怪兽条件
function c49202162.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 注册标记，表示使用了7星以上的怪兽进行连接召唤
function c49202162.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(49202162,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(49202162,4))  --"使用7星以上的怪兽为素材连接召唤"
end
-- 判断是否使用了7星以上的怪兽进行连接召唤
function c49202162.tgcon(e)
	return e:GetHandler():GetFlagEffect(49202162)>0
end
-- 根据是否已发动过效果和场上是否存在可除外的卡决定可选择的效果选项
function c49202162.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b2=c:GetFlagEffect(49202163)==0
	-- 检测场上是否存在可除外的卡
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return true end
	local op=0
	if b2 and b3 then
		-- 选择攻击力上升效果
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,2),aux.Stringid(49202162,3))  --"攻击力上升/2次攻击/场上1张卡除外"
	elseif b2 then
		-- 选择攻击力上升或2次攻击效果
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,2))  --"攻击力上升/2次攻击"
	elseif b3 then
		-- 选择攻击力上升或场上1张卡除外效果
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1),aux.Stringid(49202162,3))*2  --"攻击力上升/场上1张卡除外"
	else
		-- 只能选择攻击力上升效果
		op=Duel.SelectOption(tp,aux.Stringid(49202162,1))  --"攻击力上升"
	end
	e:SetLabel(op)
end
-- 根据选择的效果执行对应处理
function c49202162.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力上升1500
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	elseif op==1 then
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local tct=0
			-- 判断是否为自己的回合
			if Duel.GetTurnPlayer()==tp then tct=1 end
			-- 设置该卡在下次自己回合的战斗阶段中可以作2次攻击
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetCondition(c49202162.eacon)
			-- 记录当前回合数用于判断是否为下次回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1+tct)
			c:RegisterEffect(e1)
			c:RegisterFlagEffect(49202163,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,0,1+tct)
		end
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择场上1张可除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 判断是否为下次自己的回合
function c49202162.eacon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为下次自己的回合
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 检查连接召唤使用的素材中是否存在7星以上的怪兽
function c49202162.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLevelAbove,1,nil,7) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
