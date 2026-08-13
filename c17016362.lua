--Emトラピーズ・マジシャン
-- 效果：
-- 魔法师族4星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己不会受到这张卡的攻击力以下的战斗·效果伤害。
-- ②：自己·对方的主要阶段1有1次，把这张卡1个超量素材取除，以回合玩家的场上1只其他的表侧攻击表示怪兽为对象才能发动。这个回合，那只怪兽可以作2次攻击，战斗阶段结束时破坏。
-- ③：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把1只「娱乐法师」怪兽特殊召唤。
function c17016362.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以场上魔法师族4星怪兽2只为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己不会受到这张卡的攻击力以下的战斗·效果伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c17016362.damval)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段1有1次，把这张卡1个超量素材取除，以回合玩家的场上1只其他的表侧攻击表示怪兽为对象才能发动。这个回合，那只怪兽可以作2次攻击，战斗阶段结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17016362,0))  --"多次攻击"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c17016362.mtcon)
	e2:SetCost(c17016362.mtcost)
	e2:SetTarget(c17016362.mttg)
	e2:SetOperation(c17016362.mtop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把1只「娱乐法师」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17016362,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c17016362.spcon)
	e3:SetTarget(c17016362.sptg)
	e3:SetOperation(c17016362.spop)
	c:RegisterEffect(e3)
end
-- 伤害变更函数：当受到的战斗/效果伤害不大于这张卡当前攻击力时伤害化为0，否则保留原伤害。
function c17016362.damval(e,re,val,r,rp,rc)
	local atk=e:GetHandler():GetAttack()
	if val<=atk then return 0 else return val end
end
-- ②的发动条件：当前为主要阶段1且可以进入战斗阶段。
function c17016362.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前阶段是主要阶段1，且回合玩家可以进入战斗阶段。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.IsAbleToEnterBP()
end
-- ②的发动代价：取除这张卡的1个超量素材。
function c17016362.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选条件：表侧攻击表示且没有获得额外攻击次数效果的怪兽。
function c17016362.mtfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 对象选择处理：以回合玩家场上的其他表侧攻击表示且无额外攻击效果的怪兽为对象。
function c17016362.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得当前回合玩家，用于限定对象的选择范围。
	local turnp=Duel.GetTurnPlayer()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(turnp) and c17016362.mtfilter(chkc) and chkc~=e:GetHandler() end
	-- 验证是否能在回合玩家场上找到1只满足条件的其他表侧攻击表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17016362.mtfilter,turnp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家显示选择对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作玩家从回合玩家场上选择1只符合条件的怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c17016362.mtfilter,turnp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ②效果处理：为对象怪兽赋予额外1次攻击机会，并给其设置战斗阶段结束时破坏的标记与效果。
function c17016362.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁中取得这次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local fid=c:GetFieldID()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 这个回合，那只怪兽可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(17016362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 战斗阶段结束时破坏。③：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把1只「娱乐法师」怪兽特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c17016362.descon)
		e2:SetOperation(c17016362.desop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将战斗阶段结束时的破坏效果e2注册到决斗中，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 破坏效果的条件：通过flag标记确认对象怪兽正是当初被赋予额外攻击的那只。
function c17016362.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(17016362)==e:GetLabel()
end
-- 破坏效果的操作：破坏被赋予额外攻击的对象怪兽。
function c17016362.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将对象怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
-- ③的发动条件：这张卡因战斗破坏或被对方的效果破坏并送去墓地。
function c17016362.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 特殊召唤的筛选条件：持有「娱乐法师」字段且可以被特殊召唤。
function c17016362.spfilter(c,e,tp)
	return c:IsSetCard(0xc6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③发动前的合法性检查：自己场上有空位且卡组中存在可特殊召唤的「娱乐法师」怪兽。
function c17016362.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「娱乐法师」怪兽。
		and Duel.IsExistingMatchingCard(c17016362.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只「娱乐法师」怪兽并特殊召唤。
function c17016362.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「娱乐法师」怪兽。
	local g=Duel.SelectMatchingCard(tp,c17016362.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
