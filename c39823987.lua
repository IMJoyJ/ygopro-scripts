--太陽龍インティ
-- 效果：
-- 「赤蚁」＋调整以外的怪兽1只以上
-- ①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏，给与对方那个攻击力一半数值的伤害。
-- ②：场上的这张卡被破坏的下个回合的准备阶段，以自己墓地1只「月影龙 基利亚」为对象才能发动。那只怪兽特殊召唤。
function c39823987.initial_effect(c)
	-- 为太阳龙因蒂声明其同调素材卡名「赤蚁」（卡号78275321），使其满足素材限制条件。
	aux.AddMaterialCodeList(c,78275321)
	-- 添加同调召唤手续：调整必须为「赤蚁」（卡号78275321），调整以外的怪兽任意1只以上，对应「赤蚁」＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,78275321),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果①：这张卡被战斗破坏送去墓地的场合发动。把让这张卡破坏的怪兽破坏，给与对方那个攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39823987,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c39823987.descon)
	e1:SetTarget(c39823987.destg)
	e1:SetOperation(c39823987.desop)
	c:RegisterEffect(e1)
	-- 对应效果②：场上的这张卡被破坏的下个回合的准备阶段，以自己墓地1只「月影龙 基利亚」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c39823987.regcon)
	e2:SetOperation(c39823987.regop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡位于墓地，且被战斗破坏（即被战斗破坏送去墓地）。
function c39823987.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果①的发动时处理：不取对象，但若导致这张卡破坏的怪兽仍与战斗相关，则设置破坏该怪兽和给予伤害的操作信息。
function c39823987.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetReasonCard()
	if tc:IsRelateToBattle() then
		-- 设置操作信息：本次效果包含破坏，破坏对象为使这张卡破坏的怪兽tc，数量1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		-- 设置操作信息：本次效果包含伤害，伤害对象为对方玩家（1-tp），伤害数值为那只怪兽攻击力的一半（向下取整）。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(tc:GetAttack()/2))
	end
end
-- 效果①处理时：取使这张卡被战斗破坏的怪兽，若其仍与战斗相关，则计算其攻击力一半作为伤害值，先破坏该怪兽，成功后再给予对方伤害。
function c39823987.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetReasonCard()
	if not tc:IsRelateToBattle() then return end
	local atk=math.floor(tc:GetAttack()/2)
	if atk<0 then atk=0 end
	-- 以效果破坏该怪兽，若实际破坏成功（返回值非0）则继续处理伤害。
	if Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给予对方玩家（1-tp）atk数值的伤害，伤害原因为效果。
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- 效果②登记条件的判定：这张卡被破坏前位于场上（即场上的这张卡被破坏）。
function c39823987.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 当这张卡在场上被破坏时，注册一个在下一个准备阶段可发动的诱发选发效果，用于特殊召唤墓地的「月影龙 基利亚」。
function c39823987.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果②的后半段：以自己墓地1只「月影龙 基利亚」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(39823987,2))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c39823987.spcon)
	e1:SetTarget(c39823987.sptg)
	e1:SetOperation(c39823987.spop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 记录当前回合数，以便后续条件判断是否为“下个回合”的准备阶段。
	e1:SetLabel(Duel.GetTurnCount())
	-- 将新建的特殊召唤效果注册给玩家tp，使其在满足条件时可供发动。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤效果的发动条件：当前回合数不是记录的被破坏回合数，即已到被破坏后的下一个准备阶段。
function c39823987.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合数不等于效果记录值，确保只在被破坏后的下一个准备阶段发动。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 特殊召唤对象过滤：选择自己墓地卡号为66818682的「月影龙 基利亚」，且确认它可以被特殊召唤（检查召唤条件与苏生限制）。
function c39823987.spfilter(c,e,tp)
	return c:IsCode(66818682) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标处理：选择自己墓地1只符合条件的「月影龙 基利亚」作为对象；必须满足我方主要怪兽区有空位且墓地存在对象。
function c39823987.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39823987.spfilter(chkc,e,tp) end
	-- 发动合法性检查：我方主要怪兽区域必须存在至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时墓地存在至少1只满足特殊召唤条件且可作为对象的「月影龙 基利亚」。
		and Duel.IsExistingTarget(c39823987.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「月影龙 基利亚」，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c39823987.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤对象组g中的卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得对象卡，若仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c39823987.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡（月影龙 基利亚）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡「月影龙 基利亚」以表侧表示特殊召唤到自己场上（不改变控制者）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
