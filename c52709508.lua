--A・ジェネクス・トライフォース
-- 效果：
-- 「次世代」调整＋调整以外的怪兽1只以上
-- ①：这张卡得到作为这张卡的同调素材的除调整以外的怪兽属性的以下效果。
-- ●地：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ●炎：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ●光：1回合1次，以自己墓地1只光属性怪兽为对象才能发动。那只光属性怪兽里侧守备表示特殊召唤。
function c52709508.initial_effect(c)
	-- 添加同调召唤手续，要求1只「次世代」调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 设置效果处理时检查同调素材属性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c52709508.valcheck)
	c:RegisterEffect(e1)
	-- 特殊召唤成功时触发，根据同调素材属性注册对应效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c52709508.regcon)
	e2:SetOperation(c52709508.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 遍历同调素材，提取非调整怪兽的属性并进行位运算合并
function c52709508.valcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	while tc do
		if not tc:IsType(TYPE_TUNER) then
			att=bit.bor(att,tc:GetAttribute())
		end
		tc=g:GetNext()
	end
	att=bit.band(att,0x15)
	e:SetLabel(att)
end
-- 判断是否为同调召唤且存在有效属性
function c52709508.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 根据同调素材属性注册对应的效果
function c52709508.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		-- 设置地属性效果：攻击时对方不能发动魔法·陷阱卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c52709508.aclimit)
		e1:SetCondition(c52709508.actcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(52709508,2))  --"地属性怪兽为同调素材"
	end
	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		-- 设置炎属性效果：战斗破坏怪兽时给予对方该怪兽攻击力数值的伤害
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(52709508,0))  --"伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCondition(c52709508.damcon)
		e1:SetTarget(c52709508.damtg)
		e1:SetOperation(c52709508.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(52709508,3))  --"炎属性怪兽为同调素材"
	end
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		-- 设置光属性效果：1回合1次，以自己墓地1只光属性怪兽为对象特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(52709508,1))  --"选择自己墓地1只光属性怪兽在自己场上盖放"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetTarget(c52709508.sptg)
		e1:SetOperation(c52709508.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(52709508,4))  --"光属性怪兽为同调素材"
	end
end
-- 判断是否为魔法·陷阱卡的发动
function c52709508.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为攻击方
function c52709508.actcon(e)
	-- 判断是否为攻击方
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断战斗破坏的怪兽是否在墓地且为怪兽类型
function c52709508.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击目标
	local t=Duel.GetAttackTarget()
	-- 若为攻击阶段结束时，则获取攻击方
	if ev==1 then t=Duel.GetAttacker() end
	e:SetLabel(t:GetAttack())
	return t:IsLocation(LOCATION_GRAVE) and t:IsType(TYPE_MONSTER)
end
-- 设置伤害效果的目标玩家和参数
function c52709508.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的目标参数为伤害值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 执行伤害效果
function c52709508.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断墓地光属性怪兽是否可以特殊召唤
function c52709508.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 选择墓地光属性怪兽作为特殊召唤对象
function c52709508.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52709508.spfilter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c52709508.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标墓地光属性怪兽
	local g=Duel.SelectTarget(tp,c52709508.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c52709508.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_LIGHT)
		-- 将目标怪兽特殊召唤到场上
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 确认对方看到特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
