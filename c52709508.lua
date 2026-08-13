--A・ジェネクス・トライフォース
-- 效果：
-- 「次世代」调整＋调整以外的怪兽1只以上
-- ①：这张卡得到作为这张卡的同调素材的除调整以外的怪兽属性的以下效果。
-- ●地：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ●炎：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
-- ●光：1回合1次，以自己墓地1只光属性怪兽为对象才能发动。那只光属性怪兽里侧守备表示特殊召唤。
function c52709508.initial_effect(c)
	-- 为这张卡添加同调召唤手续：同调素材需要1只「次世代」调整怪兽＋1只以上调整以外的任意怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡得到作为这张卡的同调素材的除调整以外的怪兽属性的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c52709508.valcheck)
	c:RegisterEffect(e1)
	-- ①：这张卡得到作为这张卡的同调素材的除调整以外的怪兽属性的以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c52709508.regcon)
	e2:SetOperation(c52709508.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 遍历同调素材，将其中除调整以外的怪兽的属性按位累加，并只保留地、炎、光三种属性（0x15），存入效果标签，供后续注册对应属性效果使用。
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
-- 该效果注册的条件：这张卡是同调召唤成功，且素材中除调整以外怪兽的属性标签不为0（即存在地、炎、光中的至少一种属性）。
function c52709508.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 根据素材属性标签，为这张卡分别注册对应的属性效果：地属性赋予对方不能发动魔陷的限制，炎属性赋予战斗破坏怪兽时给予伤害的效果，光属性赋予1回合1次里侧守备特召墓地光属性怪兽的效果；同时给客户端添加对应属性素材的提示标志。
function c52709508.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		-- ●地：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
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
		-- ●炎：这张卡战斗破坏怪兽的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
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
		-- ●光：1回合1次，以自己墓地1只光属性怪兽为对象才能发动。那只光属性怪兽里侧守备表示特殊召唤。
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
-- 该限制效果的判定函数：只禁止「魔法·陷阱卡的发动行为」（re为EFFECT_TYPE_ACTIVATE类型的发动效果），而不是禁止效果的使用。
function c52709508.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 该限制效果的适用条件：当前进行攻击的怪兽必须是这张卡自身。
function c52709508.actcon(e)
	-- 判断当前攻击怪兽是否为这张卡自身。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 炎效果的发动条件：判定这张卡战斗破坏了怪兽，确定被破坏怪兽（通常为攻击对象；ev为1时取攻击怪兽），记录其攻击力，并确认被破坏怪兽在墓地且为怪兽。
function c52709508.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 默认获取攻击目标作为被这张卡战斗破坏的怪兽。
	local t=Duel.GetAttackTarget()
	-- 若事件参数ev为1（表示被战斗破坏的是攻击怪兽），则改为取攻击怪兽作为被破坏的怪兽。
	if ev==1 then t=Duel.GetAttacker() end
	e:SetLabel(t:GetAttack())
	return t:IsLocation(LOCATION_GRAVE) and t:IsType(TYPE_MONSTER)
end
-- 炎效果的发动目标设定：不取对象，将对方玩家登记为伤害对象，伤害数值设为标签中保存的攻击力，并登记操作信息为给予伤害。
function c52709508.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的伤害目标玩家设为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的伤害参数设为保存的被破坏怪兽的攻击力。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记操作信息：本连锁将造成伤害，目标为对方，伤害数值为保存的攻击力（用于其他卡片的发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 炎效果的实际处理：从连锁信息中取出目标玩家和伤害数值，对目标玩家造成效果伤害。
function c52709508.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中保存的伤害目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式，对目标玩家造成对应伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 光效果对象的过滤条件：该怪兽是光属性，且可以被玩家tp以里侧守备表示形式特殊召唤。
function c52709508.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 光效果的发动目标选择：检查对象合法性时，验证指定卡是自己墓地的光属性且满足特召条件；检查发动可能性时，要求自己场上有空位且墓地存在至少1只满足条件的光属性怪兽。
function c52709508.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52709508.spfilter(chkc,e,tp) end
	-- 发动条件检查时，要求自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地中存在至少1只可被选择的光属性怪兽（满足spfilter条件）时，该效果才可发动。
		and Duel.IsExistingTarget(c52709508.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要盖放的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1只满足条件的光属性怪兽，将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c52709508.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁包含特殊召唤，对象为选择的那只墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 光效果的实际处理：取出对象怪兽，确认它仍与效果关联且仍为光属性后，将其里侧守备表示特殊召唤到自己场上；若召唤成功，则向对方玩家确认该怪兽。
function c52709508.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁中登记的对象怪兽（选择的光属性墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_LIGHT)
		-- 将该对象怪兽以里侧守备表示特殊召唤到自己场上，并判断是否召唤成功。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		-- 将特殊召唤成功的里侧守备表示怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
