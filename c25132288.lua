--ライトエンド・ドラゴン
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- 这张卡进行战斗的场合，怪兽的攻击宣言时才能发动。这张卡的攻击力·守备力下降500，和这张卡进行战斗的对方怪兽的攻击力·守备力直到结束阶段时下降1500。
function c25132288.initial_effect(c)
	-- 为光辉终结龙添加同调召唤手续：素材为任意调整＋调整以外的光属性怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- 对应效果原文“这张卡进行战斗的场合，怪兽的攻击宣言时才能发动。这张卡的攻击力·守备力下降500，和这张卡进行战斗的对方怪兽的攻击力·守备力直到结束阶段时下降1500。”该段代码完整创建并注册了这个诱发选发效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25132288,0))  --"攻守下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c25132288.condition)
	e1:SetTarget(c25132288.target)
	e1:SetOperation(c25132288.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判断：这张卡进行战斗且攻击宣言时，自身攻击力·守备力均不低于500，战斗对象为表侧表示怪兽；同时将该战斗对象暂存到效果e的LabelObject中供后续使用。
function c25132288.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and c:GetAttack()>=500 and c:GetDefense()>=500 and tc:IsFaceup()
end
-- 效果发动时的目标处理：不进行选择，只让暂存的战斗对象与当前效果建立关联，以便效果处理时确认该对象仍与此连锁相关。
function c25132288.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():CreateEffectRelation(e)
end
-- 效果处理：先确认这张卡仍与效果关联且表侧表示、攻击力·守备力均不低于500，则自身攻击力·守备力各下降500；再确认战斗对象仍与效果关联且表侧表示，且这张卡不受攻守倒置效果影响，则战斗对象的攻击力·守备力直到结束阶段各下降1500。
function c25132288.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:GetAttack()>=500 and c:GetDefense()>=500 then
		-- 对应效果原文“这张卡的攻击力·守备力下降500”中的攻击力下降部分：为这张卡设置一个不会被无效的攻击力下降500的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 对应效果原文“和这张卡进行战斗的对方怪兽的攻击力·守备力直到结束阶段时下降1500”中的攻击力下降部分：为战斗对象设置一个直到结束阶段的攻击力下降1500的效果。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(-1500)
			tc:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e4)
		end
	end
end
