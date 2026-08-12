--Emトラピーズ・マジシャン
-- 效果：
-- 魔法师族4星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己不会受到这张卡的攻击力以下的战斗·效果伤害。
-- ②：自己·对方的主要阶段1有1次，把这张卡1个超量素材取除，以回合玩家的场上1只其他的表侧攻击表示怪兽为对象才能发动。这个回合，那只怪兽可以作2次攻击，战斗阶段结束时破坏。
-- ③：这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把1只「娱乐法师」怪兽特殊召唤。
function c17016362.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足魔法师族条件的4星怪兽作为素材进行2次叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己不会受到这张卡的攻击力以下的战斗·效果伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c17016362.damval)
	c:RegisterEffect(e1)
	-- 自己·对方的主要阶段1有1次，把这张卡1个超量素材取除，以回合玩家的场上1只其他的表侧攻击表示怪兽为对象才能发动。这个回合，那只怪兽可以作2次攻击，战斗阶段结束时破坏。
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
	-- 这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从卡组把1只「娱乐法师」怪兽特殊召唤。
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
-- 当受到的伤害值小于等于自身攻击力时，将伤害值归零；否则保持原伤害值
function c17016362.damval(e,re,val,r,rp,rc)
	local atk=e:GetHandler():GetAttack()
	if val<=atk then return 0 else return val end
end
-- 判断当前是否为主要阶段1且回合玩家可以进入战斗阶段
function c17016362.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1且回合玩家可以进入战斗阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.IsAbleToEnterBP()
end
-- 支付1个超量素材作为费用
function c17016362.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选条件：表侧攻击表示且未拥有额外攻击效果的怪兽
function c17016362.mtfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 选择目标：回合玩家场上1只表侧攻击表示且未拥有额外攻击效果的怪兽
function c17016362.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合玩家
	local turnp=Duel.GetTurnPlayer()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(turnp) and c17016362.mtfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c17016362.mtfilter,turnp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c17016362.mtfilter,turnp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 为选中的目标怪兽添加额外攻击效果，使其可进行2次攻击，并设置战斗阶段结束时破坏效果
function c17016362.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local fid=c:GetFieldID()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 为对象怪兽添加额外攻击效果，使其可进行2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(17016362,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 注册持续效果，在战斗阶段开始时破坏对象怪兽
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
		-- 将效果注册到玩家环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否为对应场上的怪兽触发破坏效果
function c17016362.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(17016362)==e:GetLabel()
end
-- 将对象怪兽破坏
function c17016362.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 破坏对象怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 判断该卡是否因战斗或对方效果破坏并送入墓地
function c17016362.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
end
-- 筛选条件：属于娱乐法师卡组且可特殊召唤的怪兽
function c17016362.spfilter(c,e,tp)
	return c:IsSetCard(0xc6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件
function c17016362.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c17016362.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组中选择1只满足条件的怪兽进行特殊召唤
function c17016362.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c17016362.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
